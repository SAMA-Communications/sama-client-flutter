import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';

import '../../../../api/api.dart';
import '../../../../db/models/conversation.dart';
import '../../../../repository/messages/messages_repository.dart';
import '../../../../shared/utils/file_utils.dart';
import '../../../../shared/utils/media_utils.dart';

part 'media_sender_event.dart';

part 'media_sender_state.dart';

const maxAttachmentSize = 100; // in MB
const maxAttachmentsCount = 10;

class MediaSenderBloc extends Bloc<MediaSenderEvent, MediaSenderState> {
  final ConversationModel currentConversation;
  final MessagesRepository messagesRepository;

  MediaSenderBloc({
    required this.currentConversation,
    required this.messagesRepository,
  }) : super(MediaSenderState()) {
    on<PickMoreFiles>(
      _onPickFiles,
    );

    on<ChangeMessage>(
      _onMessageChanged,
    );

    on<_AddFiles>(
      _onFilesAdded,
    );

    on<RemoveFile>(
      _onRemoveFile,
    );

    on<_CleanError>(
      _onCleanError,
    );

    on<SendMessage>(
      _onSendMessage,
    );

    on<CancelSelection>(
      _onCancelSelection,
    );

    _pickMedia();
  }

  FutureOr<void> _onPickFiles(
      PickMoreFiles event, Emitter<MediaSenderState> emit) {
    emit(state.copyWith(status: MediaSelectorStatus.picking));
    _pickMedia();
  }

  FutureOr<void> _onFilesAdded(
      _AddFiles event, Emitter<MediaSenderState> emit) {
    emit(state.copyWith(status: MediaSelectorStatus.mediaSelected));
    if (event.error?.isNotEmpty ?? false) {
      emit(state.copyWith(error: event.error));
      Timer(const Duration(seconds: 4), () {
        add(const _CleanError());
      });
    }

    var existFiles = [...state.selectedFiles];
    var newFiles = event.selectedFiles;

    if (newFiles.isEmpty) return Future.value(null);

    Set<String> errors = {};

    newFiles.removeWhere((file) {
      if (file.lengthSync() > maxAttachmentSize * megaByte) {
        errors.add(
            'One or more files are larger than $maxAttachmentSize megabytes');
        return true;
      }

      return existFiles.contains(file);
    });

    if (existFiles.length + newFiles.length > maxAttachmentsCount) {
      errors.add(
          'A maximum of $maxAttachmentsCount files are available for sending');
    }

    if (errors.isNotEmpty) {
      emit(state.copyWith(error: errors.join('\n')));
      Timer(const Duration(seconds: 4), () {
        add(const _CleanError());
      });
    }

    newFiles = newFiles.take(maxAttachmentsCount - existFiles.length).toList();

    emit(state.copyWith(selectedFiles: [...state.selectedFiles, ...newFiles]));
  }

  FutureOr<void> _onRemoveFile(
      RemoveFile event, Emitter<MediaSenderState> emit) {
    var selectedFiles = [...state.selectedFiles];
    selectedFiles.removeWhere((file) => file.path == event.fileToRemove.path);

    emit(state.copyWith(selectedFiles: selectedFiles));
  }

  FutureOr<void> _onCleanError(
      _CleanError event, Emitter<MediaSenderState> emit) {
    emit(state.copyWith(error: ''));
  }

  FutureOr<void> _onSendMessage(
      SendMessage event, Emitter<MediaSenderState> emit) async {
    emit(state.copyWith(status: MediaSelectorStatus.processing));

    try {
      var attachments = <Attachment>[];
      var body = state.message.trim().isEmpty ? null : state.message.trim();

      var selectedFiles = state.selectedFiles;
      var filesToUpload = <File>[];
      var filesBlurHash = <String, String?>{};

      for (var file in selectedFiles) {
        var compressedFile = await compressFile(file);
        filesToUpload.add(compressedFile);

        filesBlurHash[basename(compressedFile.path)] =
            await getMediaBlurHash(compressedFile);
      }

      await uploadFiles(filesToUpload, (fileName, progress) {
        state.progressController.add(MapEntry(fileName, progress));
      }).then((uploadedAttachments) {
        for (var uploadedAttachment in uploadedAttachments) {
          attachments.add(Attachment(
              fileId: uploadedAttachment.fileId,
              fileName: uploadedAttachment.fileName,
              fileBlurHash: filesBlurHash[uploadedAttachment.fileName]));
        }
      });

      await messagesRepository.sendMediaMessage(currentConversation.id,
          body: body, attachments: attachments);
      emit(state.copyWith(status: MediaSelectorStatus.processingFinished));
    } catch (e) {
      emit(state.copyWith(
          status: MediaSelectorStatus.sendingFailed,
          error: 'Can\'t send media due to some error(s)'));
      Timer(const Duration(seconds: 4), () {
        add(const _CleanError());
      });
    }
  }

  FutureOr<void> _onCancelSelection(
      CancelSelection event, Emitter<MediaSenderState> emit) {
    emit(state.copyWith(status: MediaSelectorStatus.canceled));
  }

  void _pickMedia() {
    FilePicker.platform
        .pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              ...supportedImageAttachmentExtentions,
              ...supportedVideoAttachmentExtentions
            ],
            allowMultiple: true,
            compressionQuality: 0)
        .then((result) {
      var files = result?.files;
      if (files?.isEmpty ?? true) {
        add(const _AddFiles([]));
      } else {
        var files = List<File>.from(result?.files
                .map((platformFile) => File(platformFile.path!))
                .toList() ??
            []);
        add(_AddFiles(files));
      }
    }).catchError((onError) {
      add(const _AddFiles([],
          error: 'Please allow permission access to Gallery'));
    });
  }

  FutureOr<void> _onMessageChanged(
      ChangeMessage event, Emitter<MediaSenderState> emit) {
    emit(state.copyWith(message: event.message));
  }
}
