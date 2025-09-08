#include <stdio.h>
#include <stdint.h>

#define MAX_PACKET_SIZE 128

// FSM States
typedef enum { IDLE, HEADER, PAYLOAD, DROP, DONE } State;

// Metadata STRUCT
typedef struct {
    uint32_t length : 12;
    uint32_t type   : 4;
    uint32_t dest   : 8;
    uint32_t src    : 8;
} TUserMeta;

// UNION: same data ko dono tarike se access
typedef union {
    TUserMeta meta;
    uint32_t tuser;
} EncodedMeta;

// Parser
void axi_stream_packet_parser(uint8_t *packet_ptr, int packet_size, int packet_num) {
    State state = IDLE;
    EncodedMeta e;

    printf("\n Packet #%d Received\n", packet_num);

    while (state != DONE) {
        switch (state) {
            case IDLE:
                state = HEADER;
                break;

            case HEADER:
                if (packet_size < 8) {
                    printf("Invalid Packet (too small)\n");
                    state = DROP;
                    break;
                }

                // Header parsing (8 bytes: src, dest, type, length)
                e.meta.src    = *(packet_ptr);         // byte 0
                e.meta.dest   = *(packet_ptr + 2);     // byte 2
                e.meta.type   = *(packet_ptr + 4);     // byte 4
                e.meta.length = (*(packet_ptr + 6) << 8) | *(packet_ptr + 7); // bytes 6-7

                printf(" Encoded tuser: 0x%08X\n", e.tuser);
                printf("   ➤ Source: 0x%02X\n", e.meta.src);
                printf("   ➤ Dest:   0x%02X\n", e.meta.dest);
                printf("   ➤ Type:   0x%X\n", e.meta.type);
                printf("   ➤ Length: %d bytes\n", e.meta.length);

                if (e.meta.length + 8 > packet_size) {
                    printf("  Payload exceeds packet size. Dropping.\n");
                    state = DROP;
                } else {
                    state = (e.meta.type == 0x4 || e.meta.type == 0x6) ? PAYLOAD : DROP;
                }
                break;

            case PAYLOAD:
                printf("  Forwarding Payload: ");
                for (int i = 8; i < 8 + e.meta.length; i++)
                    printf("%02X ", *(packet_ptr + i));
                printf("\n  Payload Forwarded\n");
                state = DONE;
                break;

            case DROP:
                printf("  Packet Dropped\n");
                state = DONE;
                break;
        }
    }
    printf(" Packet #%d Parsing Complete\n", packet_num);
}

// ================== MAIN FUNCTION ==================
int main() {
    printf(" AXI-Stream Packet Parser Simulation Start\n");

    // Packet #1 (valid type=0x4)
    uint8_t packet1[] = {
        0x12, 0x00, 0xAB, 0x00, 0x04, 0x00, 0x00, 0x04, // header
        0xAA, 0xBB, 0xCC, 0xDD                         // payload
    };
    axi_stream_packet_parser(packet1, sizeof(packet1), 1);

    // Packet #2 (valid type=0x6)
    uint8_t packet2[] = {
        0x10, 0x00, 0x30, 0x00, 0x06, 0x00, 0x00, 0x04, // header
        0x11, 0x22, 0x33, 0x44                         // payload
    };
    axi_stream_packet_parser(packet2, sizeof(packet2), 2);

    // Packet #3 (length > actual size → drop)
    uint8_t packet3[] = {
        0x11, 0x00, 0x33, 0x00, 0x04, 0x00, 0x00, 0xFF, // header (len=255)
        0xAA, 0xBB, 0xCC                               // payload sirf 3 bytes
    };
    axi_stream_packet_parser(packet3, sizeof(packet3), 3);

    printf("\n  Simulation Completed\n");
    return 0;
}
