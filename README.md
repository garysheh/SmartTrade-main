# SmartTrade: Empowering Stock Trading Platform with Pairs Trading Algorithms and Machine Learning Insights

## Introduction

The University of Hong Kong MSc(CompSc) Project of 2023: msp23076

For more information, please visit https://wp2023.cs.hku.hk/msp23076/ .

Our project files are divided into two parts, one is “pairs_trading_with_machine_learning-master”, which Zikang Lin is responsible for developing and maintaining, and the other is “SmartTrade-main”, which LIANG Guoxun and SHE Jiayao are responsible for developing and maintaining. 

## Getting Started

Our project SmartTrade App runs on the Xcode platform, and the programming language is mainly Swift and a few installation parts for Ruby. The simulator device is iPhone 15 Pro etc.  

### Prerequisites

Requirements for the software and other tools to build, test, and push 
- Xcode
- CocoaPods installed on the system
```
sudo gem install cocoapods
```

### Installing

Open the terminal and navigate to the project's root directory where the Podfile is located.
```
cd /path/to/your/project
```
Create the Podfile:
```
pod init
```
Then open the Podfile for editing:
```
open Podfile
```
Replace the contents of the Podfile with the following (Ruby):

```ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SmartTrade' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SmartTrade
  
  pod 'MBProgressHUD'
  pod 'Loaf'
end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
# Uncomment the following lines if you need additional Flutter build settings
#    installer.pods_project.targets.each do |target|
#        flutter_additional_ios_build_settings(target)
#    end
end
```

After the installation, open the created SmartTrade.xcworkspace file in Xcode. All CocoaPods and project-related dependencies are included in the file

## Running the project

Once get into xcworkspace initially and click the run button, will take some time to load all dependencies for the project and deploy the environment.

## Deployment

Add additional notes to deploy this on a live system

## Problems and Solutions

### Missing Product Package: 
    1. Show the hidden file of the project, and delete the "SmartTrade-main/SmartTrade.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    2. Xcode -> Product -> Clean Buid Folder 
    3. Terminal -> cd "your path" -> pod install
    4. Xcode Run

If you meet this problem, please 

## Versioning

We use Github for versioning. For the versions
available, see the [SmartTrade-main](https://github.com/garysheh/SmartTrade-main.git).

## Authors

  - **Zikang Lin** - *Developed smart trading strategy algorithm and provided potential trade pair data* -
  - **LIANG Guoxun** - *Backend development and main trading flow* -
  - **SHE Jiayao** - *API Integration and Frontend development* -


