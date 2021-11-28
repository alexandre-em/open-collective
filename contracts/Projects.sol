// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

import "./Entreprise.sol";

contract Projects is Entreprises {

    uint[] private allProjectsID;
    uint private randNonce = 10;
    uint private randProjectID = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 100000;
    uint private bountiesCounter = 0;//ADD

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
        uint256 projectBalance;
        address[] projectContributors;
        uint nbTransactions;
        bool registered;
    }

    //ADD
    struct Bountie {
        uint linkedProjectID;
        uint bountieID;
        uint256 price;
        string bountieName;
        address winnerAddress;
        bool bountieFounded;
        bool registered;
    }

    mapping(address => ProjectsOwner) private owners;
    mapping(uint => Project) private projects;
    mapping(uint => Bountie[]) private bounties;//ADD

    /**
    * @dev An utilitary function for create a new project for the msg.sender (User)
    * If the User have already a project in the contract, the ID of this project is added in the project ID List
    * This project is mapped wih his project ID in the projects List
    * msg.value will be added with the project balance
    * If the User have any project in the contract, the owner of this project is mapped with his address in the owners List and the ID of this project is added in the project ID List
    * This project is mapped wih his project ID in the projects List
    * msg.value will be added with the project balance 
    * @param _projectName { string }
    */
    function createProject(string memory _projectName) external payable {
        require(bytes(_projectName).length > 0, "Project name not valide");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        
        uint index;
        bool founded;
        Project memory newProject = initializeNewProject(_projectName);

        if(owners[msg.sender].registered) 
        {
            (index, founded) = zeroIndex(1);
            if(founded)
            {
                owners[msg.sender].projectsIDList[index] = newProject.projectID;
            }
            else
            {
                owners[msg.sender].projectsIDList.push(newProject.projectID);
            }
            owners[msg.sender].nbProjects++;
            projects[newProject.projectID] = newProject;
            (index, founded) = zeroIndex(2);
            if(founded)
            {
                 allProjectsID[index] = newProject.projectID;
            }
            else
            {
                allProjectsID.push(newProject.projectID);
            }
        }
        else 
        {
            ProjectsOwner memory newOwner;
            newOwner.ownerAddress = msg.sender;
            newOwner.nbProjects = 0;
            newOwner.registered = true;
            owners[msg.sender] = newOwner;

            (index, founded) = zeroIndex(1);
            if(founded)
            {
                owners[msg.sender].projectsIDList[index] = newProject.projectID;
            }
            else
            {
                owners[msg.sender].projectsIDList.push(newProject.projectID);
            }
            owners[msg.sender].nbProjects++;
            projects[newProject.projectID] = newProject;
            (index, founded) = zeroIndex(2);
            if(founded)
            {
                 allProjectsID[index] = newProject.projectID;
            }
            else
            {
                allProjectsID.push(newProject.projectID);
            } 
        }
        return newProject.projectID;
    }

    /**
    * @dev An utilitary internal function for find index ID = 0 in ID List
    * If find ID = 0, so return index of the ID=0 and boolean True
    * When you delete an element of List(uint), this element become a 0, so new ID replace this 0 when creating a new project
    * 2 types because 2 List of ID need to be update
    * @param _type { uint }
    * return { uint, bool }
    */
    function zeroIndex(uint _type) internal view returns (uint index, bool founded) {
        if(_type == 1)
        {
            for(uint i=0; i < owners[msg.sender].projectsIDList.length; i++)
            {
                if(owners[msg.sender].projectsIDList[i] == 0)
                {
                    return (i, true);
                }
            }
        }
        else if(_type == 2)
        {
            for(uint i=0; i < allProjectsID.length; i++)
            {
                if(allProjectsID[i] == 0)
                {
                    return (i, true);
                }
            }
        }
        else 
        {
            return (0, false);
        }
    }

    /**
    * @dev An utilitary internal function for initialize a new project
    * Create a new Project
    * Add a random unused ID to this project
    * @param _projectName { string }
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
    function getProjectDetails(uint projectID) external view returns (uint, address, string memory, uint256, uint, uint, bool) {
        require(projects[projectID].registered, "Any project exists with this ID");
        return (projects[projectID].projectID, projects[projectID].projectOwnerAddress, projects[projectID].projectName, projects[projectID].projectBalance, projects[projectID].projectContributors.length, projects[projectID].nbTransactions, projects[projectID].registered);
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
    * @param pID { uint }
    */
    function addContributor(uint pID, address newContributor) external {
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
    * @param pID { uint }
    */
    function closeProject(uint pID) external {
        require(owners[msg.sender].registered, "You have not any registered project");
        bool idFounded = false;
        uint index;
        for(uint i=0; i < owners[msg.sender].projectsIDList.length; i++)
        {
            if(owners[msg.sender].projectsIDList[i] == pID)
            {
                idFounded = true;
                index = i;
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

        delete projects[pID];
        delete owners[msg.sender].projectsIDList[index];
        for(uint j=0; j < allProjectsID.length; j++)
        {
            if(allProjectsID[j] == pID)
            {
                delete allProjectsID[j];
                break;
            }
        }
    }

    //ADD

    /**
    * @dev An utilitary function to add bountie to a project
    * Only the owner of the project add bountie to this project
    * @param pID,_bountieName  { uint, string }
    */
    function addBountie(uint pID, string memory _bountieName) external payable {
        require(owners[msg.sender].registered, "You have not any registered project");
        require(bytes(_bountieName).length > 0, "Bountie name not valide");
        require(msg.value > 0, "Amount of the transaction need to be upper than 0");
        bool idFounded = false;
        uint index;
        for(uint i=0; i < owners[msg.sender].projectsIDList.length; i++)
        {
            if(owners[msg.sender].projectsIDList[i] == pID)
            {
                idFounded = true;
                index = i;
                break;
            }
        }
        require(projects[pID].registered && idFounded, "Any project exists with this ID");

        Bountie memory newBountie;
        newBountie.linkedProjectID = pID;
        newBountie.bountieID = bountiesCounter;
        newBountie.price = msg.value;
        newBountie.bountieName = _bountieName;
        newBountie.bountieFounded = false;
        newBountie.registered = true;

        bounties[pID].push(newBountie);
        bountiesCounter++;
    }

    /**
    * @dev An utilitary function to remove bountie to a project
    * Only the owner of the project can remove bountie to this project
    * @param pID, _bountieID  { uint, uint }
    */
    function removeBountie(uint pID, uint _bountieID) external {
        require(owners[msg.sender].registered, "You have not any registered project");
        bool idFounded = false;
        uint index;
        for(uint i=0; i < owners[msg.sender].projectsIDList.length; i++)
        {
            if(owners[msg.sender].projectsIDList[i] == pID)
            {
                idFounded = true;
                index = i;
                break;
            }
        }
        require(projects[pID].registered && idFounded, "Any project exists with this ID");

        for(uint i=0; i < bounties[pID].length; i++)
        {
            if(bounties[pID][i].registered && bounties[pID][i].bountieID == _bountieID)
            {
                if(bounties[pID][i].bountieFounded)
                {
                    address payable _owner = payable(bounties[pID][i].winnerAddress);
                    _owner.transfer(bounties[pID][i].price);
                }
                else
                {
                    address payable _owner = payable(msg.sender);
                    _owner.transfer(bounties[pID][i].price);
                }
            }
        }
    }

    /**
    * @dev An utilitary function to get the list of bounties ID of the project
    * @param pID  { uint }
    * return { uint[] }
    */
    function getBountiesID(uint pID) external view returns(uint[] memory) {
        require(projects[pID].registered, "Any project exists with this ID");
        uint[] memory idList = new uint[](bounties[pID].length);

        for(uint i=0; i < bounties[pID].length; i++)
        {
            idList[i] = bounties[pID][i].bountieID;
        }

        return idList;
    }

    /**
    * @dev An utilitary function to activate the bountie by the author who fixed a bountie
    * This function return true if the bountie exists (author win the boundie)
    * This function return false if the bountie does not exist (author give the wrong boundie ID)
    * @param pID, _bountieID { uint, uint }
    * return { uint[] }
    */
    function winBountie(uint pID, uint _bountieID) external returns (bool) {
        require(projects[pID].registered, "Any project exists with this ID");

        bool bountieWinned;
        for(uint i=0; i < bounties[pID].length; i++)
        {
            if(bounties[pID][i].registered && bounties[pID][i].bountieID == _bountieID)
            {
                bounties[pID][i].bountieFounded = true;
                bounties[pID][i].winnerAddress = msg.sender;
                bountieWinned = true;
                break;
            }
            bountieWinned = false;
        }
        return bountieWinned;
    } 
}
