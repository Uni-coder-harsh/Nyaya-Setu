// Top-level build file where you can add configuration options common to all sub-projects/modules.

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Force resolution for AGP 8.7.3 compatibility across all subprojects
    subprojects {
        configurations.all {
            resolutionStrategy {
                force("androidx.browser:browser:1.8.0")
                force("androidx.core:core-ktx:1.13.1")
                force("androidx.core:core:1.13.1")
            }
        }
    }
}

// Custom build directory logic
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}