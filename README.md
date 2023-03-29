# open_polito_api

This is the Dart version of open-polito-api (https://github.com/open-polito/open-polito-api).

## Development notes

This library uses `freezed` and `json_serializable` for code generation. Run `dart run build_runner build --delete-conflicting-outputs` to update the generated code.

## To do

Features to port from the original code:

- [ ] booking
- [ ] course
- [ ] courses
- [x] device
- [ ] example
- [ ] exam_sessions
- [ ] material
- [ ] notifications
- [ ] tickets
- [ ] timetable
- [x] user
- [x] utils

## License

This package is licensed under the terms of the GNU AGPL-3.0 license.
