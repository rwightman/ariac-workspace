#!/bin/bash
rosrun osrf_gear gear.py -f /workspace/src/osrf/ariac_example/config/sample_gear_conf.yaml `catkin_find --share osrf_gear`/config/qual1a.yaml &> /output/gazebo.txt &
roslaunch --wait ur10_moveit_config ur10_moveit_planning_execution.launch sim:=true &> /output/moveit.txt &
roslaunch --wait ur10_moveit_config moveit_rviz.launch config:=true &> /output/rviz-mv.txt &
until rostopic list ; do sleep 1; done
rosrun rviz rviz -d `catkin_find osrf_gear --share`/rviz/ariac.rviz $> /output/rviz-tf.txt &
cd /workspace/src/hwl_node/scripts
#jupyter notebook --ip='*' --NotebookApp.token='' &
