// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hotel{
    
    address Admin;
    constructor() {
        Admin = msg.sender;
    }
    modifier OnlyAdmin(){
        require(msg.sender==Admin,"Only Admin Can Add Members");
        _;
    }

// Adding new Hotel details by the Admin of the Organization 
    address[] Hoteladdress;
    mapping(address => bool) Existinghotel;

    struct hotelinfo{
        address h_add;
        string h_name;
        uint numberofRooms;
        uint AvailableRooms;
    }
    mapping(address=>hotelinfo) Hdetails;

    function AddNewHotel(address _add,string memory _name,uint _rooms,uint _avarooms) OnlyAdmin public {
        Hdetails[_add]=hotelinfo(_add,_name,_rooms,_avarooms);
        Hoteladdress.push(_add);
        Existinghotel[_add]=true;
    }

// Adding new Customer  details in the LEDGER 
    uint[] RoomsBooked;
    address[] customeraddress;
    mapping(address => bool) ExistingCust;
    struct CustInfo{
        address _Cadd;
        address _add;
        string _Cname;
        uint _phn;
        uint RoomNumber;
        bool PaymentStatus;
    }
    mapping(uint=>mapping(address=>CustInfo)) CustDetails;  // NESTED MAPPING ROOM NUMBER WITH ADDRESS

    function addNewCustomers(address _cadd,address _add,string memory _cname, uint Phn, uint roomnumber) public {
        require(Existinghotel[msg.sender]!=false,"HOTEL IS NOT REGISTERED !");
        require(roomnumber <=Hdetails[_add].numberofRooms,"Room Number is Out of LIMIT");
        require(CustDetails[roomnumber][_cadd].RoomNumber != roomnumber,"You can't use the same ROOM NUMBER");
        require(Hdetails[_add].AvailableRooms!=0,"Rooms are Not Available!");
        CustDetails[roomnumber][_cadd]=CustInfo(_cadd,_add,_cname,Phn,roomnumber,false);
        
        customeraddress.push(_cadd);
        ExistingCust[_cadd]=true;
        Hdetails[_add].AvailableRooms --;
        RoomsBooked.push(roomnumber);

    }
// SEARCH FOR THE ROOMS 
    function SearchForRooms(address _add) public view returns(string memory, uint, uint[] memory){
        require(Existinghotel[msg.sender]!=false,"HOTEL IS NOT REGISTERED !");
        return(Hdetails[_add].h_name,Hdetails[_add].AvailableRooms, RoomsBooked);
    }

// BOOKING ---------------
    function ConfirmBooking(address _add,address _cadd,uint roomnumber) payable public {
        require(ExistingCust[msg.sender]!=false,"Customer will to Pay !");
        if(roomnumber >5){
            require(msg.value == 2 ether,"Insufficient Amount!");
            payable(_add).transfer(2 ether);
            CustDetails[roomnumber][_cadd].PaymentStatus=true;
        }
        else if(roomnumber <=5){
            require(msg.value == 1 ether,"Insufficient Amount!");
            payable(_add).transfer(1 ether);
            CustDetails[roomnumber][_cadd].PaymentStatus=true;
        }
    }
// FETCH CUSTOMER AND HOTEL DETAILS
    function get_CustomersInfo(address _cadd, uint roomnumber) view 
    public returns(address, address, string memory, uint, uint, bool) {
        require(Existinghotel[msg.sender]!=false,"HOTEL IS NOT REGISTERED !");
        return( CustDetails[roomnumber][_cadd]._Cadd,
                CustDetails[roomnumber][_cadd]._add,
                CustDetails[roomnumber][_cadd]._Cname,
                CustDetails[roomnumber][_cadd]._phn,
                CustDetails[roomnumber][_cadd].RoomNumber,
                CustDetails[roomnumber][_cadd].PaymentStatus);
    }

    function get_HotelInfo(address _add) view
    public returns(address, string memory, uint, uint,uint[] memory) {
        return(Hdetails[_add].h_add,
               Hdetails[_add].h_name,
               Hdetails[_add].numberofRooms,
               Hdetails[_add].AvailableRooms,
               RoomsBooked);
    }
}
