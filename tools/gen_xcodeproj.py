#!/usr/bin/env python3
"""Regenerate BridgeBuddies.xcodeproj from the source tree.

The project is generated rather than hand-maintained so adding a folder is a
re-run, not a merge conflict in a 900-line pbxproj. Xcode can still edit the
result normally — regenerate only when the file layout changes substantially.

    python3 tools/gen_xcodeproj.py
"""
import os
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT = os.path.join(ROOT, "BridgeBuddies.xcodeproj")
APP_SRC = "BridgeBuddies/BridgeBuddies"
TEST_SRC = "BridgeBuddies/Tests/CoreTests"
DEPLOYMENT_TARGET = "17.0"
BUNDLE_ID = "com.bridgebuddies.app"

_counter = [0]
def uid():
    _counter[0] += 1
    return f"BB{_counter[0]:022X}"


def swift_files(rel_dir):
    """Every .swift under rel_dir, grouped by immediate subfolder."""
    base = os.path.join(ROOT, rel_dir)
    groups = {}
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames.sort()
        files = sorted(f for f in filenames if f.endswith(".swift"))
        if not files:
            continue
        rel = os.path.relpath(dirpath, base)
        groups[rel] = files
    return groups


class Project:
    def __init__(self):
        self.objects = []          # (uid, isa-block-name, body)
        self.app_sources = []      # build-file uids
        self.test_sources = []
        self.groups = {}

    def add(self, section, body):
        u = uid()
        self.objects.append((u, section, body))
        return u


def build():
    p = Project()

    # ---- file references + build files -------------------------------------
    def add_tree(rel_dir, sources_list, group_name):
        child_group_uids = []
        for rel, files in sorted(swift_files(rel_dir).items()):
            file_uids = []
            for name in files:
                path = name
                fref = p.add("PBXFileReference",
                    f'{{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; '
                    f'path = "{path}"; sourceTree = "<group>"; }}')
                bfile = p.add("PBXBuildFile",
                    f'{{isa = PBXBuildFile; fileRef = {fref}; }}')
                sources_list.append((bfile, name))
                file_uids.append((fref, name))

            children = ",\n\t\t\t\t".join(f"{u} /* {n} */" for u, n in file_uids)
            folder = os.path.basename(rel) if rel != "." else group_name
            gpath = "" if rel == "." else f'path = "{rel}"; '
            g = p.add("PBXGroup",
                '{isa = PBXGroup; children = (\n\t\t\t\t'
                + children
                + ',\n\t\t\t); ' + gpath + f'name = "{folder}"; sourceTree = "<group>"; }}')
            child_group_uids.append((g, folder, rel))
        return child_group_uids

    app_children = add_tree(APP_SRC, p.app_sources, "BridgeBuddies")
    test_children = add_tree(TEST_SRC, p.test_sources, "CoreTests")

    plist_ref = p.add("PBXFileReference",
        '{isa = PBXFileReference; lastKnownFileType = text.plist.xml; '
        'path = "Info.plist"; sourceTree = "<group>"; }')

    app_group = p.add("PBXGroup",
        '{isa = PBXGroup; children = (\n\t\t\t\t'
        + ",\n\t\t\t\t".join(f"{u} /* {n} */" for u, n, _ in app_children)
        + f',\n\t\t\t\t{plist_ref} /* Info.plist */,'
        + f'\n\t\t\t); path = "{APP_SRC}"; name = "BridgeBuddies"; sourceTree = "<group>"; }}')

    test_group = p.add("PBXGroup",
        '{isa = PBXGroup; children = (\n\t\t\t\t'
        + ",\n\t\t\t\t".join(f"{u} /* {n} */" for u, n, _ in test_children)
        + f',\n\t\t\t); path = "{TEST_SRC}"; name = "Tests"; sourceTree = "<group>"; }}')

    app_product = p.add("PBXFileReference",
        '{isa = PBXFileReference; explicitFileType = wrapper.application; '
        'includeInIndex = 0; path = "BridgeBuddies.app"; sourceTree = BUILT_PRODUCTS_DIR; }')
    test_product = p.add("PBXFileReference",
        '{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; '
        'includeInIndex = 0; path = "BridgeBuddiesTests.xctest"; sourceTree = BUILT_PRODUCTS_DIR; }')

    products_group = p.add("PBXGroup",
        f'{{isa = PBXGroup; children = (\n\t\t\t\t{app_product} /* BridgeBuddies.app */,'
        f'\n\t\t\t\t{test_product} /* BridgeBuddiesTests.xctest */,'
        '\n\t\t\t); name = Products; sourceTree = "<group>"; }')

    root_group = p.add("PBXGroup",
        f'{{isa = PBXGroup; children = (\n\t\t\t\t{app_group} /* BridgeBuddies */,'
        f'\n\t\t\t\t{test_group} /* Tests */,'
        f'\n\t\t\t\t{products_group} /* Products */,'
        '\n\t\t\t); sourceTree = "<group>"; }')

    # ---- build phases ------------------------------------------------------
    def sources_phase(items):
        return p.add("PBXSourcesBuildPhase",
            '{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (\n\t\t\t\t'
            + ",\n\t\t\t\t".join(f"{u} /* {n} */" for u, n in items)
            + ',\n\t\t\t); runOnlyForDeploymentPostprocessing = 0; }')

    app_sources_phase = sources_phase(p.app_sources)
    test_sources_phase = sources_phase(p.test_sources)
    app_frameworks = p.add("PBXFrameworksBuildPhase",
        '{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = ( '
        '); runOnlyForDeploymentPostprocessing = 0; }')
    test_frameworks = p.add("PBXFrameworksBuildPhase",
        '{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = ( '
        '); runOnlyForDeploymentPostprocessing = 0; }')
    app_resources = p.add("PBXResourcesBuildPhase",
        '{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ( '
        '); runOnlyForDeploymentPostprocessing = 0; }')

    # ---- build settings ----------------------------------------------------
    shared = f'''
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_NO_COMMON_BLOCKS = YES;
				IPHONEOS_DEPLOYMENT_TARGET = {DEPLOYMENT_TARGET};
				SDKROOT = iphoneos;
				SWIFT_VERSION = 5.0;'''

    proj_debug = p.add("XCBuildConfiguration",
        '{isa = XCBuildConfiguration; buildSettings = {' + shared + '''
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_TESTABILITY = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				ONLY_ACTIVE_ARCH = YES;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}; name = Debug; }''')
    proj_release = p.add("XCBuildConfiguration",
        '{isa = XCBuildConfiguration; buildSettings = {' + shared + '''
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				SWIFT_COMPILATION_MODE = wholemodule;
			}; name = Release; }''')

    app_settings = f'''
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "{APP_SRC}/Resources/Info.plist";
				LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks");
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = "{BUNDLE_ID}";
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				TARGETED_DEVICE_FAMILY = 1;'''
    app_debug = p.add("XCBuildConfiguration",
        '{isa = XCBuildConfiguration; buildSettings = {' + app_settings + '\n\t\t\t}; name = Debug; }')
    app_release = p.add("XCBuildConfiguration",
        '{isa = XCBuildConfiguration; buildSettings = {' + app_settings + '\n\t\t\t}; name = Release; }')

    test_settings = f'''
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				GENERATE_INFOPLIST_FILE = YES;
				PRODUCT_BUNDLE_IDENTIFIER = "{BUNDLE_ID}.tests";
				PRODUCT_NAME = "$(TARGET_NAME)";
				TARGETED_DEVICE_FAMILY = 1;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/BridgeBuddies.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/BridgeBuddies";'''
    test_debug = p.add("XCBuildConfiguration",
        '{isa = XCBuildConfiguration; buildSettings = {' + test_settings + '\n\t\t\t}; name = Debug; }')
    test_release = p.add("XCBuildConfiguration",
        '{isa = XCBuildConfiguration; buildSettings = {' + test_settings + '\n\t\t\t}; name = Release; }')

    def conf_list(debug, release):
        return p.add("XCConfigurationList",
            f'{{isa = XCConfigurationList; buildConfigurations = (\n\t\t\t\t{debug} /* Debug */,'
            f'\n\t\t\t\t{release} /* Release */,\n\t\t\t); '
            'defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }')

    proj_conf = conf_list(proj_debug, proj_release)
    app_conf = conf_list(app_debug, app_release)
    test_conf = conf_list(test_debug, test_release)

    # ---- targets -----------------------------------------------------------
    app_target = p.add("PBXNativeTarget",
        f'{{isa = PBXNativeTarget; buildConfigurationList = {app_conf}; buildPhases = ('
        f'\n\t\t\t\t{app_sources_phase},\n\t\t\t\t{app_frameworks},\n\t\t\t\t{app_resources},'
        '\n\t\t\t); buildRules = ( ); dependencies = ( ); name = BridgeBuddies; '
        f'productName = BridgeBuddies; productReference = {app_product}; '
        'productType = "com.apple.product-type.application"; }')

    proxy = p.add("PBXContainerItemProxy",
        '{isa = PBXContainerItemProxy; containerPortal = PROJECT_UID; proxyType = 1; '
        f'remoteGlobalIDString = {app_target}; remoteInfo = BridgeBuddies; }}')
    dependency = p.add("PBXTargetDependency",
        f'{{isa = PBXTargetDependency; target = {app_target}; targetProxy = {proxy}; }}')

    test_target = p.add("PBXNativeTarget",
        f'{{isa = PBXNativeTarget; buildConfigurationList = {test_conf}; buildPhases = ('
        f'\n\t\t\t\t{test_sources_phase},\n\t\t\t\t{test_frameworks},'
        f'\n\t\t\t); buildRules = ( ); dependencies = (\n\t\t\t\t{dependency},\n\t\t\t); '
        'name = BridgeBuddiesTests; productName = BridgeBuddiesTests; '
        f'productReference = {test_product}; '
        'productType = "com.apple.product-type.bundle.unit-test"; }')

    project_uid = p.add("PBXProject",
        f'{{isa = PBXProject; attributes = {{ BuildIndependentTargetsInParallel = 1; '
        'LastSwiftUpdateCheck = 2600; LastUpgradeCheck = 2600; TargetAttributes = { '
        f'{app_target} = {{ CreatedOnToolsVersion = 26.0; }}; '
        f'{test_target} = {{ CreatedOnToolsVersion = 26.0; TestTargetID = {app_target}; }}; }}; }}; '
        f'buildConfigurationList = {proj_conf}; developmentRegion = en; hasScannedForEncodings = 0; '
        'knownRegions = (en, Base); '
        f'mainGroup = {root_group}; productRefGroup = {products_group}; '
        'projectDirPath = ""; projectRoot = ""; targets = ('
        f'\n\t\t\t\t{app_target},\n\t\t\t\t{test_target},\n\t\t\t); }}')

    # ---- emit --------------------------------------------------------------
    by_section = {}
    for u, section, body in p.objects:
        by_section.setdefault(section, []).append((u, body))

    out = ['// !$*UTF8*$!', '{', '\tarchiveVersion = 1;', '\tclasses = {', '\t};',
           '\tobjectVersion = 56;', '\tobjects = {']
    for section in sorted(by_section):
        out.append(f'\n/* Begin {section} section */')
        for u, body in by_section[section]:
            out.append(f'\t\t{u} = {body};')
        out.append(f'/* End {section} section */')
    out.append('\t};')
    out.append(f'\trootObject = {project_uid};')
    out.append('}')

    text = "\n".join(out).replace("PROJECT_UID", project_uid)

    if os.path.isdir(PROJECT):
        shutil.rmtree(PROJECT)
    os.makedirs(os.path.join(PROJECT, "xcshareddata", "xcschemes"))
    with open(os.path.join(PROJECT, "project.pbxproj"), "w") as f:
        f.write(text + "\n")

    scheme = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion = "2600" version = "1.7">
   <BuildAction parallelizeBuildables = "YES" buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting = "YES" buildForRunning = "YES" buildForProfiling = "YES" buildForArchiving = "YES" buildForAnalyzing = "YES">
            <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "{app_target}" BuildableName = "BridgeBuddies.app" BlueprintName = "BridgeBuddies" ReferencedContainer = "container:BridgeBuddies.xcodeproj"/>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference skipped = "NO">
            <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "{test_target}" BuildableName = "BridgeBuddiesTests.xctest" BlueprintName = "BridgeBuddiesTests" ReferencedContainer = "container:BridgeBuddies.xcodeproj"/>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle = "0" useCustomWorkingDirectory = "NO" ignoresPersistentStateOnLaunch = "NO" debugDocumentVersioning = "YES" debugServiceExtension = "internal" allowLocationSimulation = "YES">
      <BuildableProductRunnable runnableDebuggingMode = "0">
         <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "{app_target}" BuildableName = "BridgeBuddies.app" BlueprintName = "BridgeBuddies" ReferencedContainer = "container:BridgeBuddies.xcodeproj"/>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration = "Release" shouldUseLaunchSchemeArgsEnv = "YES" savedToolIdentifier = "" useCustomWorkingDirectory = "NO" debugDocumentVersioning = "YES">
      <BuildableProductRunnable runnableDebuggingMode = "0">
         <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "{app_target}" BuildableName = "BridgeBuddies.app" BlueprintName = "BridgeBuddies" ReferencedContainer = "container:BridgeBuddies.xcodeproj"/>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration = "Debug"/>
   <ArchiveAction buildConfiguration = "Release" revealArchiveInOrganizer = "YES"/>
</Scheme>
'''
    with open(os.path.join(PROJECT, "xcshareddata", "xcschemes", "BridgeBuddies.xcscheme"), "w") as f:
        f.write(scheme)

    print(f"generated {os.path.relpath(PROJECT, ROOT)}")
    print(f"  app target:  {len(p.app_sources)} swift files")
    print(f"  test target: {len(p.test_sources)} swift files")


if __name__ == "__main__":
    build()
