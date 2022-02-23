# Contributing

Review the following guidelines for submitting questions, issues, or changes to this repository.

## Questions

If you have issues using the SDK or have a question about the Event Notifications service, you can ask a question on [Stack Overflow](https://stackoverflow.com/questions/tagged/ibm-eventnotifications). Be sure to include the `ibm-eventnotifications` tag.

## Coding Style
This SDK follows coding style based on [Google’s iOS coding standards](https://google.github.io/swift/) for source code in the Swift Programming Language.

To ensure source code has no structural problems, run [Swift Lint](https://github.com/realm/SwiftLint#xcode) code scanning tool that helps to identify and correct problems with the structural quality of the code.

## Issues

If you encounter an issue with the iOS Destination SDK, you are welcome to submit a [bug report](https://github.com/IBM/event-notifications-destination-ios-sdk).
Before that, please search for similar issues. It's possible somebody has encountered this issue already.

## Pull Requests

If you want to contribute to the repository, here's a quick guide:

1. Fork the repository
2. Develop and test your code changes:
    * Follow the coding style as documented above
    * Please add one or more tests to validate your changes.
3. Make sure everything builds/tests cleanly.
4. Commit your changes
5. Push to your fork and submit a pull request to the `main` branch

## Running the tests

Use the Xcode test scheme or use the travis build.

## Code coverage

This repo uses [Slather](https://github.com/SlatherOrg/slather) to measure code coverage. To obtain a code coverage report, run `slather` from the `event-notifications-destination-ios-sdk` folder.


## Generating documentation

Use [jazzy](https://github.com/realm/jazzy) for document generation.

## Additional Resources

* [General GitHub documentation](https://help.github.com/)
* [GitHub pull request documentation](https://help.github.com/send-pull-requests/)

[stackoverflow]: http://stackoverflow.com/questions/ask?tags=ibm-eventnotifications


# Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
   have the right to submit it under the open source license
   indicated in the file; or

(b) The contribution is based upon previous work that, to the best
   of my knowledge, is covered under an appropriate open source
   license and I have the right under that license to submit that
   work with modifications, whether created in whole or in part
   by me, under the same open source license (unless I am
   permitted to submit under a different license), as indicated
   in the file; or

(c) The contribution was provided directly to me by some other
   person who certified (a), (b) or (c) and I have not modified
   it.

(d) I understand and agree that this project and the contribution
   are public and that a record of the contribution (including all
   personal information I submit with it, including my sign-off) is
   maintained indefinitely and may be redistributed consistent with
   this project or the open source license(s) involved.
