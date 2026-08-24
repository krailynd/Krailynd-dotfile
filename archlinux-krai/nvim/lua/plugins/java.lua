return {
  -- Extra Java IDE tweaks on top of lazyvim.plugins.extras.lang.java
  -- That extra already installs jdtls via mason, sets up nvim-jdtls with blink.cmp,
  -- lombok, debug/test bundles, inlay hints, and keymaps (<leader>co etc).
  -- Here we add IntelliJ/NetBeans-like ergonomics for EVERYDAY Java (not just Spring):
  -- organize imports on save, chain completion, smart code generation, and richer
  -- static-member suggestions for Streams, NIO, and core JDK.
  -- Decision: nvim-java/nvim-java was evaluated and SKIPPED — it replaces the
  -- jdtls setup, adds Spring-Boot UI/debug bloat, and brings nothing extra for
  -- plain Java everyday completion. Plain jdtls + blink.cmp already covers
  -- locals, methods, chains, postfix, and snippets via friendly-snippets.
  -- 2025-08-23 enhance: IntelliJ Ultimate layer (additive, no deletions):
  --   - saveActions.organizeImports auto-organize on save like IntelliJ auto-import
  --   - expanded favoriteStaticMembers (Stream, Function, CompletableFuture, etc.)
  --   - richer inlayHints (param types, var types) + CodeLens for fields/impls
  --   - signatureHelp with docs, smart semicolon, fernflower decompiler
  --   - live templates via snippets/java.json (sout/soutv/psvm/ifn/iter/itli/thr/lazy)
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      settings = {
        java = {
          configuration = {
            -- Runtimes auto-detected; explicitly list Arch JDK 26 for robustness
            runtimes = {
              {
                name = "JavaSE-26",
                path = "/usr/lib/jvm/java-26-openjdk",
                default = true,
              },
            },
            updateBuildConfiguration = "automatic",
          },
          -- Decompiler preference like IntelliJ (FernFlower)
          contentProvider = {
            preferred = "fernflower",
          },
          -- Auto-organize imports on save like IntelliJ "Optimize imports on the fly"
          saveActions = {
            organizeImports = true,
          },
          -- Signature help with docs like IntelliJ Parameter Info (Ctrl+P)
          signatureHelp = {
            enabled = true,
            description = {
              enabled = true,
            },
          },
          -- Smart semicolon detection like IntelliJ
          edit = {
            smartSemicolonDetection = {
              enabled = true,
            },
          },
          -- Maven/Gradle library detection is automatic via jdtls root markers (pom.xml/build.gradle)
          -- Ensure sources organize imports thresholds are generous
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          -- Intelligent completion like IntelliJ/NetBeans: everyday code + Spring/Maven
          -- Smart Completion = jdtls chain + postfix + guessMethodArguments + favoriteStaticMembers
          completion = {
            enabled = true,
            guessMethodArguments = true, -- insert best-guessed args for methods (IntelliJ auto-insert)
            postfix = { enabled = true }, -- .var .null .notnull .for .if .cast .new .try .opt etc
            maxResults = 0, -- uncapped: locals/Stream/snippets not hidden behind imports
            chain = { enabled = true }, -- smart a.getB().getC() chain completion (IntelliJ Chain Completion)
            importOrder = { "java", "javax", "org", "com" },
            -- Static members proposed even without import: everyday JDK first, then tests/Spring
            -- IntelliJ suggests static imports automatically; these mirror that productivity
            favoriteStaticMembers = {
              -- Everyday Java (core JDK) — most useful for daily coding
              "java.util.Objects.*",
              "java.util.Collections.*",
              "java.util.stream.Collectors.*",
              "java.util.Comparator.*",
              "java.util.Arrays.*",
              "java.nio.file.Files.*",
              "java.nio.file.Paths.*",
              "java.util.Optional.*",
              "java.lang.Math.*",
              -- Tests / assertions
              "org.junit.Assert.*",
              "org.junit.Assume.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.junit.jupiter.api.Assumptions.*",
              "org.junit.jupiter.api.DynamicContainer.*",
              "org.junit.jupiter.api.DynamicTest.*",
              "org.mockito.Mockito.*",
              "org.mockito.ArgumentMatchers.*",
              "org.mockito.Answers.*",
              "org.mockito.BDDMockito.*",
              "org.assertj.core.api.Assertions.*",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.hamcrest.MatcherAssert.assertThat",
              -- Spring
              "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
              "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
              "org.springframework.test.web.servlet.setup.MockMvcBuilders.*",
              "org.springframework.test.web.servlet.result.MockMvcResultHandlers.*",
              -- Extra productivity — IntelliJ routinely suggests these without import
              "java.util.stream.Stream.*",
              "java.util.function.Function.*",
              "java.util.function.Predicate.*",
              "java.util.concurrent.CompletableFuture.*",
              "java.util.concurrent.TimeUnit.*",
              "java.time.format.DateTimeFormatter.*",
              "org.springframework.util.Assert.*",
              "org.assertj.core.api.Assumptions.*",
            },
            -- Hide noise types (keeps AWT/com.sun out of everyday completion)
            filteredTypes = {
              "java.awt.*",
              "com.sun.*",
              "sun.*",
              "jdk.*",
              "org.graalvm.*",
              "io.micrometer.shaded.*",
            },
          },
          -- Diagnostics & inlay hints like IntelliJ (View > Inlay Hints)
          inlayHints = {
            parameterNames = {
              enabled = "all",
            },
            parameterTypes = {
              enabled = true,
            },
            variableTypes = {
              enabled = true,
            },
          },
          -- Smart code generation (hashCode/equals, toString, blocks, comments)
          codeGeneration = {
            useBlocks = true,
            generateComments = false,
            hashCodeEquals = {
              useJava7Objects = true,
              useInstanceof = false,
            },
            toString = {
              template = "${object.className} [${member.name()}=${member.value}, ${otherMembers}]",
              codeStyle = "STRING_CONCATENATION",
              skipNullValues = false,
              listArrayContents = true,
              limitElements = 0,
            },
          },
          -- Smart selection (expand selection by semantic scope) + references
          selectionRange = {
            enabled = true,
          },
          references = {
            includeAccessors = true,
            includeDecompiledSources = true,
          },
          -- Formatting & autobuild
          format = {
            enabled = true,
          },
          -- Extended client capabilities: download sources for Maven libs + Eclipse
          eclipse = {
            downloadSources = true,
          },
          maven = {
            downloadSources = true,
          },
          implementationsCodeLens = {
            enabled = true,
          },
          -- IntelliJ-like Code Vision: implementations for types+methods, references with fields
          implementationCodeLens = "all",
          referencesCodeLens = {
            enabled = true,
            includeFields = true,
          },
          -- Autobuild for Maven/Gradle
          autobuild = {
            enabled = true,
          },
        },
      },
    },
  },
}
