workflows:
  ios-workflow:
    name: iOS Workflow
    # instance_type: mac_mini
    max_build_duration: 120
    environment:
      vars:
        XCODE_WORKSPACE: "Runner.xcworkspace"
        XCODE_SCHEME: "Runner"                
        # https://docs.codemagic.io/code-signing-yaml/signing-ios/
        APP_STORE_CONNECT_ISSUER_ID: Encrypted(...) # <-- Put your encrypted App Store Connect Issuer Id here 
        APP_STORE_CONNECT_KEY_IDENTIFIER: Encrypted(...) # <-- Put your encrypted App Store Connect Key Identifier here 
        APP_STORE_CONNECT_PRIVATE_KEY: Encrypted(...) # <-- Put your encrypted App Store Connect Private Key here 
        CERTIFICATE_PRIVATE_KEY: Encrypted(...) # <-- Put your encrypted Certificate Private Key here 
        APPLE_ID: Encrypted(...) # <-- Put your encrypted Apple Id email address here
        APPLE_APP_SPECIFIC_PASSWORD: Encrypted(...) # <-- Put your encrypted App Specific password here
        BUNDLE_ID: "io.codemagic.flutteryaml" # <-- Put your bundle id here
        APP_STORE_ID: 1111111111 # <-- Use the TestFlight Apple id number (An automatically generated ID assigned to your app) found under General > App Information > Apple ID. 
      flutter: stable
      xcode: latest
      cocoapods: default
    scripts:
      - name: Set up keychain to be used for codesigning using Codemagic CLI 'keychain' command
        script: |
                    keychain initialize
      - name: Fetch signing files
        script: |
                    app-store-connect fetch-signing-files $BUNDLE_ID --type IOS_APP_STORE --create
      - name: Use system default keychain
        script: |
                    keychain add-certificates
      - name: Set up code signing settings on Xcode project
        script: |
                    xcode-project use-profiles
      - name: Get Flutter packages
        script: |
                    cd . && flutter packages pub get
      - name: Flutter analyze
        script: |
                    cd . && flutter analyze
      - name: Flutter unit tests
        script: |
                    cd . && flutter test
        ignore_failure: true          
      - name: Install pods
        script: |
                    find . -name "Podfile" -execdir pod install \;
      - name: Flutter build ipa and automatic versioning
        script: |
          flutter build ipa --release \
          --build-name=1.0.0 \
          --build-number=$(($(app-store-connect get-latest-testflight-build-number "$APP_STORE_ID") + 1)) \
          --export-options-plist=/Users/builder/export_options.plist          
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - flutter_drive.log
    publishing:
      # See the following link for details about email publishing - https://docs.codemagic.io/publishing-yaml/distribution/#email
      email:
        recipients:
          - letyraapp@gmail.com
        notify:
          success: true     # To receive a notification when a build succeeds
          failure: false    # To not receive a notification when a build fails
      slack: 
        # See the following link about how to connect your Slack account - https://docs.codemagic.io/publishing-yaml/distribution/#slack
        channel: "#builds"
        notify_on_build_start: true   # To receive a notification when a build starts
        notify:
          success: true               # To receive a notification when a build succeeds
          failure: false              # To not receive a notification when a build fails
      app_store_connect:   # https://docs.codemagic.io/publishing-yaml/distribution              
        apple_id: $APPLE_ID    
        password: $APPLE_APP_SPECIFIC_PASSWORD
