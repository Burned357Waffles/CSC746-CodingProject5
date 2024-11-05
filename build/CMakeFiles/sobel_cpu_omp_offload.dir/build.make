# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.20

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /pscratch/sd/b/bwat746/CSC746-CodingProject5

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /pscratch/sd/b/bwat746/CSC746-CodingProject5/build

# Include any dependencies generated for this target.
include CMakeFiles/sobel_cpu_omp_offload.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/sobel_cpu_omp_offload.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/sobel_cpu_omp_offload.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/sobel_cpu_omp_offload.dir/flags.make

CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.o: CMakeFiles/sobel_cpu_omp_offload.dir/flags.make
CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.o: ../sobel_cpu_omp_offload.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/pscratch/sd/b/bwat746/CSC746-CodingProject5/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.o"
	/opt/cray/pe/craype/2.7.30/bin/CC $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.o -c /pscratch/sd/b/bwat746/CSC746-CodingProject5/sobel_cpu_omp_offload.cpp

CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.i"
	/opt/cray/pe/craype/2.7.30/bin/CC $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /pscratch/sd/b/bwat746/CSC746-CodingProject5/sobel_cpu_omp_offload.cpp > CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.i

CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.s"
	/opt/cray/pe/craype/2.7.30/bin/CC $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /pscratch/sd/b/bwat746/CSC746-CodingProject5/sobel_cpu_omp_offload.cpp -o CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.s

# Object files for target sobel_cpu_omp_offload
sobel_cpu_omp_offload_OBJECTS = \
"CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.o"

# External object files for target sobel_cpu_omp_offload
sobel_cpu_omp_offload_EXTERNAL_OBJECTS =

sobel_cpu_omp_offload: CMakeFiles/sobel_cpu_omp_offload.dir/sobel_cpu_omp_offload.cpp.o
sobel_cpu_omp_offload: CMakeFiles/sobel_cpu_omp_offload.dir/build.make
sobel_cpu_omp_offload: CMakeFiles/sobel_cpu_omp_offload.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/pscratch/sd/b/bwat746/CSC746-CodingProject5/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable sobel_cpu_omp_offload"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/sobel_cpu_omp_offload.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/sobel_cpu_omp_offload.dir/build: sobel_cpu_omp_offload
.PHONY : CMakeFiles/sobel_cpu_omp_offload.dir/build

CMakeFiles/sobel_cpu_omp_offload.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/sobel_cpu_omp_offload.dir/cmake_clean.cmake
.PHONY : CMakeFiles/sobel_cpu_omp_offload.dir/clean

CMakeFiles/sobel_cpu_omp_offload.dir/depend:
	cd /pscratch/sd/b/bwat746/CSC746-CodingProject5/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /pscratch/sd/b/bwat746/CSC746-CodingProject5 /pscratch/sd/b/bwat746/CSC746-CodingProject5 /pscratch/sd/b/bwat746/CSC746-CodingProject5/build /pscratch/sd/b/bwat746/CSC746-CodingProject5/build /pscratch/sd/b/bwat746/CSC746-CodingProject5/build/CMakeFiles/sobel_cpu_omp_offload.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/sobel_cpu_omp_offload.dir/depend

