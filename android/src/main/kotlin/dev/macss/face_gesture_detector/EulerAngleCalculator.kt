package dev.macss.face_gesture_detector

import kotlin.math.atan2
import kotlin.math.sqrt

/**
 * Extracts Euler angles (pitch, yaw, roll) from MediaPipe's 4×4 facial
 * transformation matrix.
 *
 * MediaPipe returns a column-major 4×4 matrix representing the face pose
 * in 3D space. This calculator decomposes the 3×3 rotation sub-matrix
 * into intrinsic ZYX Euler angles using the standard aerospace convention:
 *
 *   pitch = atan2(-r20, √(r21² + r22²))   — rotation around X (nodding)
 *   yaw   = atan2(r10, r00)                — rotation around Y (turning)
 *   roll  = atan2(r21, r22)                — rotation around Z (tilting)
 *
 * Sign conventions match [PoseAngles] in Dart:
 *   - pitch > 0 → looking up
 *   - yaw   > 0 → turned to user's left
 *   - roll  > 0 → tilted to user's right
 *
 * Axis mapping for head pose:
 *   - X-axis (through ears)       → pitch (nodding)
 *   - Y-axis (through top of head)→ yaw   (turning)
 *   - Z-axis (through face)       → roll  (tilting)
 *
 * In ZYX decomposition R = Rz(ψ)·Ry(θ)·Rx(φ), the middle angle θ
 * corresponds to Y-axis → yaw, the outermost ψ to Z-axis → roll,
 * and the innermost φ to X-axis → pitch.
 */
object EulerAngleCalculator {

    /**
     * Computes pitch, yaw, and roll in degrees from a column-major 4×4
     * transformation matrix.
     *
     * @param matrix 16 floats in column-major order (as returned by MediaPipe).
     * @return Triple of (pitch, yaw, roll) in degrees.
     * @throws IllegalArgumentException if the matrix does not contain exactly 16 elements.
     */
    fun fromMatrix(matrix: FloatArray): Triple<Double, Double, Double> {
        require(matrix.size == 16) {
            "Transformation matrix must have exactly 16 elements, got ${matrix.size}"
        }

        // Column-major layout:
        //   col 0: [0] [1] [2] [3]
        //   col 1: [4] [5] [6] [7]
        //   col 2: [8] [9] [10] [11]
        //   col 3: [12] [13] [14] [15]
        //
        // Row-column access: element(row, col) = matrix[col * 4 + row]
        val r00 = matrix[0].toDouble()  // row 0, col 0
        val r10 = matrix[1].toDouble()  // row 1, col 0
        val r20 = matrix[2].toDouble()  // row 2, col 0
        val r21 = matrix[6].toDouble()  // row 2, col 1
        val r22 = matrix[10].toDouble() // row 2, col 2

        // ZYX decomposition: R = Rz(ψ)·Ry(θ)·Rx(φ)
        // Y-axis rotation (θ) → head yaw (turning left/right)
        val yawRad = atan2(-r20, sqrt(r21 * r21 + r22 * r22))
        // Z-axis rotation (ψ) → head roll (tilting left/right)
        val rollRad = atan2(r10, r00)
        // X-axis rotation (φ) → head pitch (nodding up/down)
        val pitchRad = atan2(r21, r22)

        return Triple(
            Math.toDegrees(pitchRad),
            Math.toDegrees(yawRad),
            Math.toDegrees(rollRad),
        )
    }
}
