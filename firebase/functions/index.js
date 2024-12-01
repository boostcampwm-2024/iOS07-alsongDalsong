const { createRoom } = require('./api/CreateRoom.js');
const { joinRoom } = require('./api/JoinRoom.js');
const { startGame } = require('./api/StartGame.js');
const { uploadRecord } = require('./api/UploadRecord.js');
const { exitRoom } = require('./api/ExitRoom.js');
const { onRemovePlayer, onRemoveRoom } = require('./trigger/onRemovePlayer.js');
const { changeMode } = require('./api/ChangeMode.js');
const { submitMusic } = require('./api/SubmitMusic');
const { submitAnswer } = require('./api/SubmitAnswer');
const { changeRecordOrder } = require('./api/ChangeRecordOrder.js');
const { resetGame } = require('./api/ResetGame.js');

const { submitMusicV2 } = require('./api/SubmitMusicV2.js');
const { submitAnswerV2 } = require('./api/SubmitAnswerV2.js');
const { uploadRecordingV2 } = require('./api/UploadRecordV2.js');

// 방 관련 API
exports.createRoom = createRoom;
exports.joinRoom = joinRoom;
exports.startGame = startGame;
exports.exitRoom = exitRoom;
exports.changeMode = changeMode;
exports.onRemoveRoom = onRemoveRoom;
exports.submitMusic = submitMusic;
exports.submitAnswer = submitAnswer;
exports.changeRecordOrder = changeRecordOrder;
exports.resetGame = resetGame;
exports.onRemovePlayer = onRemovePlayer;
exports.startGame = startGame;
exports.uploadRecording = uploadRecord;

exports.V2 = {
  uploadRecording: uploadRecordingV2,
  submitMusic: submitMusicV2,
  submitAnswer: submitAnswerV2,
};
∑