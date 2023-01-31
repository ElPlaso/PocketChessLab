import 'package:bloc/bloc.dart';
import 'package:chess_bored/chess_home/controllers/chess_game.dart';
import 'package:chess_bored/chess_home/data/chess_clock_model.dart';
import 'package:chess_bored/chess_home/data/chess_clock_settings.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

part 'chess_clock_event.dart';
part 'chess_clock_state.dart';

/// The Bloc for handling the chess clock / timer.
class ChessClockBloc extends Bloc<ChessClockEvent, ChessClockState> {
  final ChessClockModel _chessClock = GetIt.instance<ChessClockModel>();
  final ChessGame _chessGame = GetIt.instance<ChessGame>();

  ChessClockBloc() : super(ChessClockInitial()) {
    _chessClock.addListener(_onChessClockListen);
    on<ClockSetEvent>(_onClockSet);
    on<ChessClockStartedEvent>(_onChessClockStarted);
    on<PlayerMovedEvent>(_onPlayerMoved);
    on<TimeTickedEvent>(_onTimeTicked);
    on<ChessClockStoppedEvent>(_onChessClockStopped);
  }

  _onChessClockListen() {
    if (_chessClock.whiteDuration.inSeconds == 0) {
      add(ChessClockStoppedEvent());
      // TODO: handle black victory.
    } else if (_chessClock.blackDuration.inSeconds == 0) {
      add(ChessClockStoppedEvent());
      // TODO: handle white victory.
    }
    add(TimeTickedEvent());
  }

  _onClockSet(ClockSetEvent event, emit) {
    _chessClock.setClock(event.settings);
    emit(ChessClockInitial());
  }

  _onChessClockStarted(ChessClockStartedEvent event, emit) {
    // Since white's first to move, and the clock has started,
    // first start white's time.
    _chessClock.startWhiteTime();
    emit(ChessClockRunningState(
        _chessClock.whiteDuration, _chessClock.blackDuration));
  }

  _onPlayerMoved(PlayerMovedEvent event, emit) {
    if (state is ChessClockRunningState) {
      // Black has just played, so start white's clock...
      if (_chessGame.moveCount % 2 == 0) {
        _chessClock.startWhiteTime();
      } else {
        // ... and vice versa.
        _chessClock.startBlackTime();
      }
    }
  }

  _onTimeTicked(TimeTickedEvent event, emit) {
    // Emite state with new durations.
    emit(ChessClockRunningState(
        _chessClock.whiteDuration, _chessClock.blackDuration));
  }

  _onChessClockStopped(ChessClockStoppedEvent event, emit) {
    // Reset the clock to an idle state.
    emit(ChessClockInitial());
  }
}
