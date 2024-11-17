// TODO: 레코드가 생성되거나 업데이트 될 때 실행되는 함수
// IMPORTANT: 모드 별로 라운드와 Status를 변경하는 방법이 다릅니다.
// 레코드가 생성될 경우 모드에 따라 라운드와 Status 상태를 변경한다.
// 라운드 마다 녹음 파일의 갯수를 검사하여 모든 플레이어가 녹음을 완료했을 경우 다음 라운드로 넘어간다.

const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const admin = require('../FirebaseAdmin.js');

module.exports.onRecordAdded = onDocumentWritten(
  {
    document: '/rooms/{roomNumber}',
    region: 'asia-northeast3',
  },
  async (event) => {
    const roomData = event.data.after.data(); // 업데이트된 문서 데이터

    if (!roomData || !roomData.records || !roomData.players) {
      console.log('필수 필드 누락');
      return;
    }

    if (roomData.round < 1) {
      console.log('라운드 시작 전');
      return;
    }

    const playersCount = roomData.players.length;
    const currentRound = roomData.round || 0;
    const records = roomData.records;
    const currentMode = roomData.mode;

    // 현재 라운드에서 플레이어 수만큼 녹음이 완료되었는지 확인
    const currentRoundKey = `R${currentRound}`;
    const currentRoundRecords = records[0][currentRoundKey] || [];
    console.log('-------------------------------------');
    console.log(`현재 라운드: ${currentRound}`);
    console.log(`현재 라운드 녹음 수: ${currentRoundRecords.length}`);
    console.log(`플레이어 수: ${playersCount}`);
    console.log(`현재 모드: ${currentMode}`);
    console.log(`현재 라운드 녹음: ${currentRoundRecords}`);
    console.log('-------------------------------------');
    switch (currentMode) {
      case 'humming':
        if (currentRoundRecords.length === playersCount) {
          if (currentRound < playersCount) {
            await event.data.after.ref.update({
              round: currentRound + 1,
              status: 'rehumming',
            });
            console.log(`Round ${currentRound} 완료. 다음 라운드로 이동.`);
          } else {
            await event.data.after.ref.update({
              status: 'result',
            });
            console.log('모든 라운드 완료. 결과 발표.');
          }
        }
        break;
      default:
        console.log('Invalid mode');
        break;
    }
  }
);
