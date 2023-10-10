// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract LeaseContract {
    enum PropertyType {
        House,
        Shop
    }

    struct PropertyInfo {
        address owner;
        PropertyType propertyType;
        string ownerName;
        LeaseInfo leaseInfo;
    }

    struct LeaseInfo {
        address tenantAddress;
        string tenantName;
        uint256 startDate;
        uint256 endDate;
    }

    mapping(string => PropertyInfo) public properties;
    mapping(address => PropertyInfo[]) public ownerProperties;

    modifier onlyPropertyOwner(string memory propertyAddress) {
        require(
            properties[propertyAddress].owner == msg.sender,
            "Only property owner can perform this action"
        );
        _;
    }

    event LeaseStarted(
        address indexed tenantAddress,
        address indexed ownerAddress,
        string propertyAddress,
        uint256 startDate,
        uint256 endDate,
        PropertyType propertyType,
        string ownerName,
        string tenantName
    );
    event LeaseEnded(
        address indexed tenantAddress,
        address indexed ownerAddress,
        string propertyAddress,
        uint256 startDate,
        uint256 endDate,
        PropertyType propertyType,
        string ownerName,
        string tenantName
    );
    event IssueReported(
        address indexed tenantAddress,
        string propertyAddress,
        string tenantName,
        string issueDescription
    );

    function addProperty(
        string memory propertyAddress,
        PropertyType propertyType,
        string memory ownerName
    ) external {
        require(
            propertyType == PropertyType.House ||
                propertyType == PropertyType.Shop,
            "Invalid property type"
        );

        PropertyInfo storage property = properties[propertyAddress];
        property.owner = msg.sender;
        property.propertyType = propertyType;
        property.ownerName = ownerName;

        ownerProperties[msg.sender].push(property);
    }

    function startLease(
        string memory propertyAddress,
        address tenantAddress,
        string memory tenantName,
        uint256 durationDays
    ) external onlyPropertyOwner(propertyAddress) {
        require(durationDays > 0, "Invalid lease duration");

        uint256 startDate = block.timestamp;
        uint256 endDate = startDate + (durationDays * 1 days);

        PropertyInfo storage property = properties[propertyAddress];
        LeaseInfo storage lease = property.leaseInfo;
        lease.tenantAddress = tenantAddress;
        lease.tenantName = tenantName;
        lease.startDate = startDate;
        lease.endDate = endDate;

        emit LeaseStarted(
            tenantAddress,
            msg.sender,
            propertyAddress,
            startDate,
            endDate,
            property.propertyType,
            property.ownerName,
            tenantName
        );
    }

    function endLease(
        string memory propertyAddress
    ) external onlyPropertyOwner(propertyAddress) {
        PropertyInfo storage property = properties[propertyAddress];
        LeaseInfo storage lease = property.leaseInfo;
        lease.tenantAddress = address(0);
        lease.tenantName = "";
        lease.startDate = 0;
        lease.endDate = 0;

        emit LeaseEnded(
            lease.tenantAddress,
            msg.sender,
            propertyAddress,
            lease.startDate,
            lease.endDate,
            property.propertyType,
            property.ownerName,
            lease.tenantName
        );
    }

    function reportIssue(
        string memory propertyAddress,
        string memory issueDescription
    ) external {
        PropertyInfo memory property = getPropertyInfo(propertyAddress);

        emit IssueReported(
            property.leaseInfo.tenantAddress,
            propertyAddress,
            property.leaseInfo.tenantName,
            issueDescription
        );
    }

    function getOwnerProperties()
        external
        view
        returns (PropertyInfo[] memory)
    {
        return ownerProperties[msg.sender];
    }

    function getPropertyInfo(
        string memory propertyAddress
    ) public view returns (PropertyInfo memory) {
        return properties[propertyAddress];
    }
}
