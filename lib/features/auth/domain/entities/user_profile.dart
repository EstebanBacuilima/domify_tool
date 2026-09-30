import 'package:characters/characters.dart';
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.code,
    required this.email,
    required this.displayName,
  });

  final int id;
  final String code;
  final String email;
  final String displayName;

  @override
  List<Object?> get props => [id, code, email, displayName];

  /// First character of the name, falling back to the email, for an avatar.
  ///
  /// Read as graphemes and never with `[0]`: an index returns a UTF-16 code
  /// unit, which cuts an emoji or a composed character in half. The empty name
  /// is not hypothetical either — `.first` over nothing took the whole screen
  /// down, not just the avatar.
  String get initial {
    final name = displayName.trim().characters;
    if (name.isNotEmpty) {
      return name.first;
    }

    final address = email.trim().characters;
    return address.isEmpty ? '?' : address.first;
  }
}
