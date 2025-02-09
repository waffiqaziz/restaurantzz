# Running Tests Locally

To run the tests on your local machine, follow these steps:

1. Install dependencies
  
   Make sure all dependencies are up to date:

   ```bash
   flutter pub get
   ```

2. Run the Tests
  
   - To run unit and widget tests :

     ```bash
     flutter test
     ```

   - To run instrumented test:

     - On windows

        ```bash
        flutter test integration_test\feature\main\screen\main_screen_test.dart
        ```

     - On macOS

        ```bash
        flutter test integration_test
        ```

3. Test Coverage (optional)
    - Install [Chocolatey](https://chocolatey.org/install)
    - Install [lcov](https://community.chocolatey.org/packages/lcov)

      > For windows user, make sure **GENHTML** alredy added inside **Environtment Variabel** on **System variabels**.

      | Variable | Value                                                |
      |----------|------------------------------------------------------|
      | GENHTML  | C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml |

    - Run test coverage

      - linux or macOS

        ```bash
        flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
        ```

      - windows (PowerShell)

        ```bash
        flutter test --coverage && perl $env:GENHTML coverage\lcov.info -o coverage\html
        ```

      - windows (Command Prompt)

        ```bash
        flutter test --coverage && perl %GENHTML% coverage\lcov.info -o coverage\html 
        ```

    - You can see the test coverage on `.html` format inside `coverage/html` directory.
