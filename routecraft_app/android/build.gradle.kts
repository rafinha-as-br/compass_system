allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// ponytail: unifiedpush_android 3.5.0's own build.gradle.kts calls the Kotlin
// Gradle Plugin's `kotlin { compilerOptions { ... } }` extension without ever
// applying a Kotlin plugin itself (upstream packaging bug) - "kotlin" then
// resolves to an unrelated kotlin-dsl helper and the build fails with
// "Unresolved reference: compilerOptions". Force-apply the Kotlin Android
// plugin for that one subproject before its script runs. Drop this once the
// plugin fixes it upstream.
subprojects {
    if (project.name == "unifiedpush_android") {
        apply(plugin = "org.jetbrains.kotlin.android")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
