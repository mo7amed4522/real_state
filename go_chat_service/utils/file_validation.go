package utils

import (
	"bytes"
	"errors"
	"io"
	"mime/multipart"
)

var (
	allowedImageExts = map[string]bool{"png": true, "jpg": true, "jpeg": true}
	allowedAudioExts = map[string]bool{"wav": true, "mp3": true}
	maxFileSize      = int64(10 << 20) // 10 MB
)

func ValidateFile(header *multipart.FileHeader, file multipart.File) error {
	ext := getFileExt(header.Filename)
	if !allowedImageExts[ext] && !allowedAudioExts[ext] {
		return errors.New("unsupported file extension")
	}

	// Check file size
	if header.Size > maxFileSize {
		return errors.New("file too large")
	}

	// Read first 512 bytes for magic byte check
	buf := make([]byte, 512)
	n, err := file.Read(buf)
	if err != nil && err != io.EOF {
		return errors.New("failed to read file for validation")
	}
	file.Seek(0, io.SeekStart) // Reset file pointer

	if allowedImageExts[ext] {
		if !isImageMagic(buf[:n], ext) {
			return errors.New("invalid image file content")
		}
	}
	if allowedAudioExts[ext] {
		if !isAudioMagic(buf[:n], ext) {
			return errors.New("invalid audio file content")
		}
	}
	return nil
}

func getFileExt(filename string) string {
	for i := len(filename) - 1; i >= 0; i-- {
		if filename[i] == '.' {
			return lower(filename[i+1:])
		}
	}
	return ""
}

func lower(s string) string {
	b := []byte(s)
	for i := range b {
		if b[i] >= 'A' && b[i] <= 'Z' {
			b[i] += 'a' - 'A'
		}
	}
	return string(b)
}

func isImageMagic(data []byte, ext string) bool {
	switch ext {
	case "png":
		return bytes.HasPrefix(data, []byte{0x89, 0x50, 0x4E, 0x47})
	case "jpg", "jpeg":
		return bytes.HasPrefix(data, []byte{0xFF, 0xD8, 0xFF})
	}
	return false
}

func isAudioMagic(data []byte, ext string) bool {
	switch ext {
	case "wav":
		return bytes.HasPrefix(data, []byte("RIFF")) && bytes.Contains(data, []byte("WAVE"))
	case "mp3":
		return bytes.HasPrefix(data, []byte{0xFF, 0xFB}) || bytes.HasPrefix(data, []byte{0x49, 0x44, 0x33})
	}
	return false
}
