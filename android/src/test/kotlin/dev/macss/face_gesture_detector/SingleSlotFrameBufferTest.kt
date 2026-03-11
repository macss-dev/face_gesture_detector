package dev.macss.face_gesture_detector

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Assert.assertFalse
import org.junit.Test

/**
 * Unit tests for [SingleSlotFrameBuffer].
 *
 * Verifies the single-slot backpressure semantics:
 * deposit overwrites, acquire clears, and only the latest frame survives.
 */
class SingleSlotFrameBufferTest {

    @Test
    fun `newly created buffer is empty`() {
        val buffer = SingleSlotFrameBuffer<String>()

        assertTrue(buffer.isEmpty)
        assertNull(buffer.acquire())
    }

    @Test
    fun `deposit then acquire returns the deposited frame`() {
        val buffer = SingleSlotFrameBuffer<String>()

        buffer.deposit("frame-1")
        val acquired = buffer.acquire()

        assertEquals("frame-1", acquired)
    }

    @Test
    fun `acquire clears the slot`() {
        val buffer = SingleSlotFrameBuffer<String>()

        buffer.deposit("frame-1")
        buffer.acquire()

        assertTrue(buffer.isEmpty)
        assertNull(buffer.acquire())
    }

    @Test
    fun `multiple deposits keep only the latest frame`() {
        val buffer = SingleSlotFrameBuffer<String>()

        buffer.deposit("frame-1")
        buffer.deposit("frame-2")
        buffer.deposit("frame-3")

        assertEquals("frame-3", buffer.acquire())
    }

    @Test
    fun `deposit makes buffer non-empty`() {
        val buffer = SingleSlotFrameBuffer<String>()

        buffer.deposit("frame-1")

        assertFalse(buffer.isEmpty)
    }

    @Test
    fun `works with complex types`() {
        data class Frame(val bytes: ByteArray, val width: Int, val height: Int)

        val buffer = SingleSlotFrameBuffer<Frame>()
        val frame = Frame(byteArrayOf(1, 2, 3), 640, 480)

        buffer.deposit(frame)
        val acquired = buffer.acquire()

        assertEquals(640, acquired?.width)
        assertEquals(480, acquired?.height)
    }

    @Test
    fun `concurrent deposit and acquire do not lose data or crash`() {
        val buffer = SingleSlotFrameBuffer<Int>()
        val depositCount = 10_000
        val acquiredValues = mutableListOf<Int>()

        // Producer deposits sequentially increasing values
        val producer = Thread {
            for (i in 1..depositCount) {
                buffer.deposit(i)
            }
        }

        // Consumer acquires as fast as possible
        val consumer = Thread {
            for (i in 1..depositCount) {
                val value = buffer.acquire()
                if (value != null) {
                    acquiredValues.add(value)
                }
            }
        }

        producer.start()
        consumer.start()
        producer.join()
        consumer.join()

        // Acquired values must be monotonically non-decreasing
        // (we may skip frames, but never go backwards)
        for (i in 1 until acquiredValues.size) {
            assertTrue(
                "Values must be non-decreasing: ${acquiredValues[i - 1]} > ${acquiredValues[i]}",
                acquiredValues[i - 1] <= acquiredValues[i],
            )
        }
    }
}
