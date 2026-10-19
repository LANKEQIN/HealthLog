allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// 统一所有 Android 子工程（含 jni / jni_flutter 等原生插件）使用本机已完整安装的 NDK 27.0.12077973。
// 原因：jni 插件直接取 Flutter 的默认 ndkVersion（3.47.x 为 28.2.13676358），
// 而本机该版本仅为损坏的空壳；此处覆盖可避免触发 ~1GB 的 NDK 自动下载。
subprojects {
    // :app 已被上面的 evaluationDependsOn 提前评估，无法再注册 afterEvaluate，需跳过
    if (!state.executed) {
        afterEvaluate {
            extensions.findByName("android")?.let { androidExtension ->
                // 用反射调用 setter，避免根工程 buildscript 直接依赖 AGP 类型
                androidExtension.javaClass
                    .getMethod("setNdkVersion", String::class.java)
                    .invoke(androidExtension, "27.0.12077973")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
