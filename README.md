Docker steps
1- run once
./build-docker-image.bash

2- run once
./run-docker-container.bash

3- close newly created terminal

4 - shell 1
./start-docker-container.bash
cd ws/
source devel/setup.bash
roslaunch robingas_mission_gazebo husky_gazebo.launch

5- shell 2
./new_bash_in_container.bash
cd ws/
source devel/setup.bash
roslaunch robingas_mission_gazebo husky_gazebo.launch

5- shell 3
./new_bash_in_container.bash
cd ws/
source devel/setup.bash
roslaunch traversability_estimation semantic_traversability.launch input:=/points

5- shell 4
./new_bash_in_container.bash
cd ws/
source devel/setup.bash
roslaunch robingas_mission_gazebo husky_gazebo.launch

5- shell 5
./new_bash_in_container.bash
cd ws/
source devel/setup.bash
roslaunch robingas_mission_gazebo husky_gazebo.launch

