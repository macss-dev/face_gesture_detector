package dev.macss.face_gesture_detector

import android.graphics.Bitmap
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.graphics.BitmapFactory
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import java.io.ByteArrayOutputStream

/**
 * Converts camera frame bytes (NV21 format) into MediaPipe's [MPImage].
 *
 * The camera plugin sends NV21-encoded YUV420 frames. This decoder converts
 * them through the standard Android pipeline:
 *   NV21 bytes → YuvImage → JPEG compress → Bitmap → MPImage
 *
 * The JPEG intermediate step is required because Android lacks a direct
 * NV21→Bitmap decoder. JPEG quality is set to 90 for a balance between
 * speed and fidelity — ML inference is tolerant of lossy compression.
 */
object FrameDecoder {

    private const val JPEG_QUALITY = 90

    /**
     * Decodes NV21 camera bytes into an MPImage suitable for MediaPipe inference.
     *
     * @param nv21Bytes Raw NV21-encoded frame from the camera plugin.
     * @param width Frame width in pixels.
     * @param height Frame height in pixels.
     * @return MPImage wrapping an ARGB_8888 Bitmap.
     */
    fun decode(nv21Bytes: ByteArray, width: Int, height: Int): MPImage {
        val bitmap = nv21ToBitmap(nv21Bytes, width, height)
        return BitmapImageBuilder(bitmap).build()
    }

    /**
     * Converts NV21 bytes to a Bitmap via JPEG compression.
     *
     * Visible for testing — allows verifying the intermediate Bitmap
     * without requiring the full MediaPipe MPImage stack.
     */
    internal fun nv21ToBitmap(nv21Bytes: ByteArray, width: Int, height: Int): Bitmap {
        val yuvImage = YuvImage(nv21Bytes, ImageFormat.NV21, width, height, null)
        val outputStream = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, width, height), JPEG_QUALITY, outputStream)
        val jpegBytes = outputStream.toByteArray()
        return BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.size)
    }
}
