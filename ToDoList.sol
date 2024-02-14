// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract ToDoList {

    event TaskCreated(uint256 taskId, string taskDescription, uint256 deadline);
    event TaskUpdated(uint256 taskId, string taskDescription, uint256 deadline);
    event TaskRemoved(uint256 taskId);

    // enum Priority { Low, Medium, High }

    struct TaskToDo {
        string Task ;
        bool isCompleted ;
        // Priority priority;
        uint deadline;
    }

    mapping (uint => TaskToDo) public List ;

    uint256 public count = 0 ;

    address public owner;


    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addTask(string memory _task, uint256 _deadline) public onlyOwner {
        require(bytes(_task).length > 0, "Task cannot be empty");
        // require(_priority <= Priority.High, "Invalid priority level");

        TaskToDo memory ToDo = TaskToDo(_task, false, _deadline) ; // moins couteux en gas selon vidéo 1
        List[count] = ToDo ;
        emit TaskCreated(count, ToDo.Task, ToDo.deadline) ;
        count ++ ;
    }

    function getTask(uint256 _id) public view returns (TaskToDo memory) {
        require(_id < count, "Invalid todo ID");
        return List[_id];
    }

    function updateTask(uint256 _id, string memory _task , uint256 _deadline) public {
        require(_id < count, "Invalid todo ID");
        // require(_priority <= Priority.High, "Invalid priority level");
        TaskToDo memory ToDo = TaskToDo(_task, false, _deadline) ;
        List[_id] = ToDo ;
        emit TaskUpdated(_id, ToDo.Task, ToDo.deadline) ;

    }

    function removeTask(uint256 _id) public onlyOwner {
        require(_id < count, "Invalid todo ID");

        emit TaskRemoved(_id);

        delete List[_id];
        count--;

        // Shift remaining List to fill the gap
        for (uint256 i = _id; i < count; i++) {
            List[i] = List[i + 1];
        }
        delete List[count]; // dernier doublon
    }

    function CheckOrUncheckTask(uint256 _id) public {
        require(_id < count, "Invalid todo ID");
        List[_id].isCompleted = !(List[_id].isCompleted) ;
    }

    function getUpcomingTodos() public view returns (TaskToDo[] memory) {
        uint256 upcomingTodoCount = 0;
        TaskToDo[] memory upcomingTodos = new TaskToDo[](count);

        for (uint256 i = 0; i < count; i++) {
            TaskToDo memory todo = List[i];
            if (!todo.isCompleted && block.timestamp <= todo.deadline) {
                upcomingTodos[upcomingTodoCount] = todo;
                upcomingTodoCount++;
            }
        }

        return upcomingTodos;
    }

    function getOverdueTodos() public view returns (TaskToDo[] memory) {
        uint256 overdueTodoCount = 0;
        TaskToDo[] memory overdueTodos = new TaskToDo[](count);

        for (uint256 i = 0; i < count; i++) {
            TaskToDo memory todo = List[i];
            if (!todo.isCompleted && block.timestamp > todo.deadline) {
                overdueTodos[overdueTodoCount] = todo;
                overdueTodoCount++;
            }
        }

        return overdueTodos;
    }


}