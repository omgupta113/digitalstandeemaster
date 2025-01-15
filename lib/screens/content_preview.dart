// content_preview.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/content_model.dart';

class ContentPreview extends StatefulWidget {
  final Content content;

  ContentPreview({required this.content});

  @override
  _ContentPreviewState createState() => _ContentPreviewState();
}

class _ContentPreviewState extends State<ContentPreview> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String? _pdfPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeContent();
  }

  Future<void> _initializeContent() async {
    if (widget.content.type == 'mp4') {
      _videoController = VideoPlayerController.network(widget.content.url)
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
        });
    } else if (widget.content.type == 'pdf') {
      await _downloadPDF();
    }
  }

  Future<void> _downloadPDF() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(widget.content.url));
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(bytes);

      setState(() {
        _pdfPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    // Clean up temporary PDF file
    if (_pdfPath != null) {
      File(_pdfPath!).delete().catchError((e) => print('Error deleting temp file: $e'));
    }
    super.dispose();
  }

  Widget _buildPreview() {
    switch (widget.content.type.toLowerCase()) {
      case 'pdf':
        if (_isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (_pdfPath == null) {
          return Center(child: Text('Error loading PDF'));
        }
        return PDFView(
          filePath: _pdfPath!,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: true,
          pageFling: true,
          onError: (error) {
            print('Error loading PDF: $error');
          },
          onPageError: (page, error) {
            print('Error loading page $page: $error');
          },
        );
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
        return CachedNetworkImage(
          imageUrl: widget.content.url,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.contain,
        );

      case 'mp4':
      case 'video':
        if (_isVideoInitialized) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      setState(() {
                        _videoController!.value.isPlaying
                            ? _videoController!.pause()
                            : _videoController!.play();
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.replay),
                    onPressed: () {
                      _videoController!.seekTo(Duration.zero);
                    },
                  ),
                ],
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }

      default:
        return Center(
          child: Text('Unsupported content type: ${widget.content.type}'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.name),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Content Details'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${widget.content.name}'),
                      Text('Type: ${widget.content.type}'),
                      Text('Duration: ${widget.content.displayDuration} seconds'),
                      Text('Sequence: ${widget.content.sequence}'),
                      Text('Created: ${widget.content.createdAt.toString()}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _buildPreview(),
        ),
      ),
    );
  }
}