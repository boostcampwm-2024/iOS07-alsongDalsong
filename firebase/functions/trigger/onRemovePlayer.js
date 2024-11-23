const { onValueDeleted } = require('firebase-functions/v2/database');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');

const admin = require('../FirebaseAdmin.js');

module.exports.onRemoveRoom = onDocumentWritten(
  {
    ref: '/rooms/{roomNumber}',
    region: 'asia-southeast1',
  },
  async (event) => {
    const roomData = event.data.after.data(); // 업데이트된 문서 데이터

    if (!roomData || !roomData.players) {
      console.log('필수 필드 누락');
      return;
    }

    const playersCount = roomData.players.length;
    if (playersCount === 0) {
      await event.data.after.ref.delete();
      console.log(`Room ${event.params.roomNumber} deleted because all players left.`);
    }
  }
);

module.exports.onRemovePlayer = onValueDeleted(
  {
    ref: '/players/{playerid}',
    region: 'asia-southeast1',
  },
  async (context) => {
    const playerId = context.params.playerid; // 삭제된 player ID
    const roomsRef = admin.firestore().collection('rooms');

    try {
      // Firestore rooms 조회
      const roomsSnapshot = await roomsRef.get();

      for (const roomDoc of roomsSnapshot.docs) {
        const roomData = roomDoc.data();

        // players 필드가 없으면 스킵
        if (!roomData.players || !Array.isArray(roomData.players)) {
          continue;
        }

        // players에서 삭제된 playerId 필터링
        const updatedPlayers = roomData.players.filter((player) => player.id !== playerId);

        if (updatedPlayers.length !== roomData.players.length) {
          const roomRef = roomsRef.doc(roomDoc.id);

          if (roomData.host?.id === playerId) {
            // 호스트가 나간 경우
            if (updatedPlayers.length > 0) {
              // 남은 플레이어 중 랜덤으로 호스트 지정
              const newHost = updatedPlayers[Math.floor(Math.random() * updatedPlayers.length)];
              await roomRef.update({
                host: newHost,
                players: updatedPlayers,
              });
              console.log(`Player ${playerId} removed. New host: ${newHost.id}`);
            } else {
              // 남은 플레이어가 없는 경우 방 삭제
              await roomRef.delete();
              console.log(`Room ${roomDoc.id} deleted because all players left.`);
            }
          } else {
            // 일반 플레이어가 나간 경우
            await roomRef.update({
              players: updatedPlayers,
            });
            console.log(`Player ${playerId} removed from room ${roomDoc.id}.`);
          }
        }
      }
    } catch (error) {
      console.error(`Error processing player removal for ${playerId}:`, error);
    }
  }
);
