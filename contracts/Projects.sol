// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract Projects {

    uint[] allProjectsID;
    uint randNonce = 10;
    uint randProjectID = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 100000;

    struct ProjectsOwner {
        address ownerAddress;
        uint nbProjects;
        uint[] projectsIDList;
        bool registered;
    }

    struct Project {
        uint projectID;
        address projectOwnerAddress;
        string projectName;
        uint projectBalance;
        address[] projectContributors;
        uint nbTransactions;
        bool registered;
    }

    mapping(address => ProjectsOwner) private owners;
    mapping(uint => Project) private projects;

    /**
    * @dev An utilitary function for create a new project for the msg.sender (User)
    * If the User have already a project in the contract, the ID of this project is added in the project ID List
    * This project is mapped wih his project ID in the projects List
    * msg.value will be added with the project balance
    * If the User have any project in the contract, the owner of this project is mapped with his address in the owners List and the ID of this project is added in the project ID List
    * This project is mapped wih his project ID in the projects List
    * msg.value will be added with the project balance 
    * @param _username { string }
    */
    function createProject(string memory _projectName) external payable {
        require(bytes(_projectName).length > 0, "Username not valide");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");

        Project memory newProject = initializeNewProject(_projectName);

        if(owners[msg.sender].registered) 
        {
            owners[msg.sender].projectsIDList.push(newProject.projectID);
            owners[msg.sender].nbProjects++;
            projects[newProject.projectID] = newProject;
            allProjectsID.push(newProject.projectID);
        }
        else 
        {
            ProjectsOwner memory newOwner;
            newOwner.ownerAddress = msg.sender;
            newOwner.nbProjects = 0;
            newOwner.registered = true;
            owners[msg.sender] = newOwner;

            owners[msg.sender].projectsIDList.push(newProject.projectID);
            owners[msg.sender].nbProjects++;
            projects[newProject.projectID] = newProject;
            allProjectsID.push(newProject.projectID);  
        }
    }

    /**
    * @dev An utilitary internal function for initialize a new project
    * Create a new Project
    * Add a random unused ID to this project
    * @param _username { string }
    * return { Project }
    */
    function initializeNewProject(string memory _projectName) internal returns (Project memory) {

        Project memory newProject;
        newProject.projectOwnerAddress = msg.sender;
        newProject.projectName = _projectName;
        newProject.projectBalance = msg.value;
        newProject.nbTransactions = 1;
        newProject.registered = true;

        while(projects[randProjectID].registered)
        {
            randNonce++;
            randProjectID = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 100000;
        }
        newProject.projectID = randProjectID;

        return newProject;
    }

    /**
    * @dev An utilitary function to get details about the msg.sender (owner) project account
    * Only the owner can have details of his project account
    * return { address, uint, uint[] }
    */
    function getOwnerProjects() external view returns (address, uint, uint [] memory) {
        require(owners[msg.sender].registered, "You have not any registered project");
        return (msg.sender, owners[msg.sender].nbProjects, owners[msg.sender].projectsIDList);
    }

    /**
    * @dev An utilitary function to get all ID of all projects of this contract
    * Everyboby can have this list of ID for sponsoring projects (choose an ID and use sponsoringProject() method to put money on this project)
    * return { uint[] }
    */
    function getAllProjectsID() external view returns (uint[] memory) {
        return allProjectsID;
    }

    /**
    * @dev An utilitary function to get all details about the selected project of this contract
    * Everyboby can have details of a project for sponsoring this project (Use sponsoringProject() method with this project ID to put money on this project)
    * @param projectID { uint }
    * return { uint, address, string, uint, uint, uint }
    */
    function getProjectDetails(uint projectID) external view returns (uint, address, string memory, uint, uint, uint) {
        require(projects[projectID].registered, "Any project exists with this ID");
        return (projects[projectID].projectID, projects[projectID].projectOwnerAddress, projects[projectID].projectName, projects[projectID].projectBalance, projects[projectID].projectContributors.length, projects[projectID].nbTransactions);
    }

    /**
    * @dev An utilitary function to put money on a project with the ID of this project
    * Everyboby can sponsor a project
    * @param projectID { uint }
    */
    function sponsoringProject(uint projectID) external payable {
        require(projects[projectID].registered, "Any project exists with this ID");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        projects[projectID].projectBalance += msg.value;
    }

    /**
    * @dev An utilitary function to add a contributor on an project
    * Only the owner of the project can add contributor on this project
    * @param projectID { uint }
    */
    function addContributor(uint pID, address newContributor) external payable {
        require(owners[msg.sender].registered, "You have not any registered project");
        bool idFounded = false;
        for(uint i=0; i < owners[msg.sender].projectsIDList.length; i++)
        {
            if(owners[msg.sender].projectsIDList[i] == pID)
            {
                idFounded = true;
                break;
            }
        }
        require(projects[pID].registered && idFounded, "Any project exists with this ID");

        projects[pID].projectContributors.push(newContributor);
    }

    /**
    * @dev An utilitary function to close the project
    * Only the owner of the project can close this project
    * the project balance will divided by the number of the contributors and the share will be sended to each contributor
    * @param projectID { uint }
    */
    function closeProject(uint pID) external {
        require(owners[msg.sender].registered, "You have not any registered project");
        bool idFounded = false;
        for(uint i=0; i < owners[msg.sender].projectsIDList.length; i++)
        {
            if(owners[msg.sender].projectsIDList[i] == pID)
            {
                idFounded = true;
                break;
            }
        }
        require(projects[pID].registered && idFounded, "Any project exists with this ID");
        require(projects[pID].projectContributors.length > 0, "Project have any contributor");

        uint share = projects[pID].projectBalance / projects[pID].projectContributors.length;

        for(uint i=0; i < projects[pID].projectContributors.length; i++)
        {
            if(i==(projects[pID].projectContributors.length-1))
            {
                address payable _owner = payable(projects[pID].projectContributors[i]);
                _owner.transfer(projects[pID].projectBalance);
                projects[pID].projectBalance = 0;
            }
            else
            {
                address payable _owner = payable(projects[pID].projectContributors[i]);
                _owner.transfer(share);
                projects[pID].projectBalance -= share;
            }
        }
    }
}