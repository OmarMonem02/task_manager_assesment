import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final LogoutUseCase _logoutUseCase;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _logoutUseCase = logoutUseCase,
        super(ProfileInitial()) {
    on<LoadProfileRequested>(_onLoadProfile);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLoadProfile(
    LoadProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _getProfileUseCase();
      emit(ProfileLoaded(profile));
    } on ServerFailure catch (e) {
      emit(ProfileError(e.message));
    } on UnauthorizedFailure catch (e) {
      emit(ProfileError(e.message));
    } on CacheFailure catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(const ProfileError('Failed to load profile'));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final profile = state is ProfileLoaded ? (state as ProfileLoaded).profile : null;
    try {
      await _logoutUseCase();
      emit(ProfileLogoutSuccess());
    } catch (e) {
      if (profile != null) {
        emit(ProfileLoaded(profile, snackbarMessage: 'Failed to logout'));
      } else {
        emit(const ProfileError('Failed to logout'));
      }
    }
  }
}
