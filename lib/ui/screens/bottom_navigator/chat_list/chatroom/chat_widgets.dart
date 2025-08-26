import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/models/message.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class BottomFeild extends StatelessWidget {
  const BottomFeild({
    super.key, 
    this.onTap, 
    this.onChanged, 
    this.controller,
    this.onFilePicked,
  });

  final void Function()? onTap;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final void Function(PlatformFile file, FileType type)? onFilePicked;

  Future<void> _pickFile(BuildContext context, FileType type) async {
    Navigator.pop(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Check file size (limit to 10MB for example)
        if (file.size > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size too large. Please select a file under 10MB.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: ${file.name}')),
        );
        
        // Call the callback if provided
        onFilePicked?.call(file, type);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              16.verticalSpace,
              ListTile(
                leading: Icon(Icons.photo, color: Primary),
                title: const Text('Photos'),
                onTap: () => _pickFile(context, FileType.image),
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: Primary),
                title: const Text('Videos'),
                onTap: () => _pickFile(context, FileType.video),
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file, color: Primary),
                title: const Text('Document'),
                onTap: () => _pickFile(context, FileType.any),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Primary),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera feature coming soon!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: grey.withOpacity(0.2),
      padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 20.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => _showAttachmentOptions(context),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: white,
              child: const Icon(Icons.add),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: CustomTextField(
              controller: controller,
              isChatText: true,
              hintText: "Type a message",
              onChanged: onChanged,
              onTap: onTap, // Keep the original onTap for send functionality
            ),
          )
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key, 
    this.isCurrentUser = true, 
    required this.message,
    this.showTimestamp = true,
  });

  final bool isCurrentUser;
  final Message message;
  final bool showTimestamp;

  @override
  Widget build(BuildContext context) {
    final borderRadius = isCurrentUser
        ? BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          );
    
    final alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: 1.sw * 0.75, minWidth: 50.w),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isCurrentUser ? Primary : grey.withOpacity(0.2),
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser 
              ? CrossAxisAlignment.start 
              : CrossAxisAlignment.end,
          children: [
            Text(
              message.text ?? '', // Using message.text instead of message.content
              style: body.copyWith(
                color: isCurrentUser ? white : null,
              ),
            ),
            5.verticalSpace,
            Text(
              DateFormat('hh:mm a').format(message.timestamp!),
              style: small.copyWith(
                color: isCurrentUser ? white : null,
              ),
            )
          ],
        ),
      ),
    );
  }
}