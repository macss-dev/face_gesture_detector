package dev.macss.face_gesture_detector

import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Test

/**
 * Unit tests for [EulerAngleCalculator].
 *
 * Verifies Euler angle extraction from known 4×4 rotation matrices
 * in column-major order (as returned by MediaPipe).
 *
 * Axis-to-head-pose mapping (ZYX decomposition):
 *   X-axis rotation → pitch (nodding up/down)
 *   Y-axis rotation → yaw   (turning left/right)
 *   Z-axis rotation → roll  (tilting left/right)
 */
class EulerAngleCalculatorTest {

    private val angleTolerance = 0.01

    @Test
    fun `identity matrix yields zero angles`() {
        val identity = floatArrayOf(
            1f, 0f, 0f, 0f,
            0f, 1f, 0f, 0f,
            0f, 0f, 1f, 0f,
            0f, 0f, 0f, 1f,
        )

        val (pitch, yaw, roll) = EulerAngleCalculator.fromMatrix(identity)

        assertEquals(0.0, pitch, angleTolerance)
        assertEquals(0.0, yaw, angleTolerance)
        assertEquals(0.0, roll, angleTolerance)
    }

    @Test
    fun `90 degree Y rotation maps to yaw (looking left)`() {
        // R_y(90°) column-major:
        //   col0=[cos90, 0, -sin90, 0] = [0, 0, -1, 0]
        //   col1=[0, 1, 0, 0]
        //   col2=[sin90, 0, cos90, 0]  = [1, 0, 0, 0]
        //   col3=[0, 0, 0, 1]
        val yaw90 = floatArrayOf(
            0f, 0f, -1f, 0f,
            0f, 1f, 0f, 0f,
            1f, 0f, 0f, 0f,
            0f, 0f, 0f, 1f,
        )

        val (pitch, yaw, roll) = EulerAngleCalculator.fromMatrix(yaw90)

        assertEquals(0.0, pitch, angleTolerance)
        assertEquals(90.0, yaw, angleTolerance)
        assertEquals(0.0, roll, angleTolerance)
    }

    @Test
    fun `45 degree X rotation maps to pitch (looking up)`() {
        // R_x(45°) column-major:
        //   col0=[1, 0, 0, 0]
        //   col1=[0, cos45, sin45, 0]
        //   col2=[0, -sin45, cos45, 0]
        //   col3=[0, 0, 0, 1]
        val cos45 = 0.7071068f
        val sin45 = 0.7071068f
        val pitch45 = floatArrayOf(
            1f, 0f, 0f, 0f,
            0f, cos45, sin45, 0f,
            0f, -sin45, cos45, 0f,
            0f, 0f, 0f, 1f,
        )

        val (pitch, yaw, roll) = EulerAngleCalculator.fromMatrix(pitch45)

        assertEquals(45.0, pitch, angleTolerance)
        assertEquals(0.0, yaw, angleTolerance)
        assertEquals(0.0, roll, angleTolerance)
    }

    @Test
    fun `30 degree Z rotation maps to roll (tilting right)`() {
        // R_z(30°) column-major:
        //   col0=[cos30, sin30, 0, 0]
        //   col1=[-sin30, cos30, 0, 0]
        //   col2=[0, 0, 1, 0]
        //   col3=[0, 0, 0, 1]
        val cos30 = 0.8660254f
        val sin30 = 0.5f
        val roll30 = floatArrayOf(
            cos30, sin30, 0f, 0f,
            -sin30, cos30, 0f, 0f,
            0f, 0f, 1f, 0f,
            0f, 0f, 0f, 1f,
        )

        val (pitch, yaw, roll) = EulerAngleCalculator.fromMatrix(roll30)

        assertEquals(0.0, pitch, angleTolerance)
        assertEquals(0.0, yaw, angleTolerance)
        assertEquals(30.0, roll, angleTolerance)
    }

    @Test
    fun `negative Y rotation maps to negative yaw (looking right)`() {
        // R_y(-45°) column-major:
        //   cos(-45)=cos45, sin(-45)=-sin45
        //   col0=[cos45, 0, sin45, 0]
        //   col1=[0, 1, 0, 0]
        //   col2=[-sin45, 0, cos45, 0]
        //   col3=[0, 0, 0, 1]
        val cos45 = 0.7071068f
        val sin45 = 0.7071068f
        val yawNeg45 = floatArrayOf(
            cos45, 0f, sin45, 0f,
            0f, 1f, 0f, 0f,
            -sin45, 0f, cos45, 0f,
            0f, 0f, 0f, 1f,
        )

        val (pitch, yaw, roll) = EulerAngleCalculator.fromMatrix(yawNeg45)

        assertEquals(0.0, pitch, angleTolerance)
        assertEquals(-45.0, yaw, angleTolerance)
        assertEquals(0.0, roll, angleTolerance)
    }

    @Test
    fun `matrix with fewer than 16 elements throws`() {
        val shortMatrix = floatArrayOf(1f, 0f, 0f)

        val exception = assertThrows(IllegalArgumentException::class.java) {
            EulerAngleCalculator.fromMatrix(shortMatrix)
        }

        assertEquals(
            "Transformation matrix must have exactly 16 elements, got 3",
            exception.message,
        )
    }

    @Test
    fun `translation components do not affect angles`() {
        // Identity rotation with non-zero translation in col 3
        val translated = floatArrayOf(
            1f, 0f, 0f, 0f,
            0f, 1f, 0f, 0f,
            0f, 0f, 1f, 0f,
            100f, 200f, 300f, 1f,
        )

        val (pitch, yaw, roll) = EulerAngleCalculator.fromMatrix(translated)

        assertEquals(0.0, pitch, angleTolerance)
        assertEquals(0.0, yaw, angleTolerance)
        assertEquals(0.0, roll, angleTolerance)
    }
}
