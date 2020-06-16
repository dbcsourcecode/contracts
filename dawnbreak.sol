/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }

}

contract UsdtInterface {
    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint supply);
    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public;
    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint _value) public;
}

contract Utils {

    function genId(address user)
	public
	pure
	returns(bytes32)
    {
	return keccak256(abi.encodePacked(user));
    }

    function pow6()
        public
        pure
        returns(uint256)
    {
        return (uint256)(10 ** 6);
    }

    modifier noContract(address user) {
        require(is_contract(user) == 0,"no contract user!");
        _;
    }
}

contract BasicContract is Utils {

    using SafeMath for uint256;

    uint256 public startDay;
    uint256 public period = 86400;
    UsdtInterface public UsdtToken;

    uint256 public incomeLimit = pow6().mul(100000);
    uint256 public touchTimes = 0;
    uint256 public touchLimits = 2;
    uint256 public difficutityModiferTimes = 0;
    mapping(uint256 => uint256) public incomeOneDay;
    mapping(uint256 => bool) public outOfControlOneDay;

    function nowDay()
        public
        view
        returns(uint256)
    {
        return now.div(period);
    }

    function liControl(uint256 amount)
        internal
    {
        require(outOfControlOneDay[nowDay()] == false,"limit control");
        incomeOneDay[nowDay()] = incomeOneDay[nowDay()].add(amount);
        if(incomeOneDay[nowDay()] >= incomeLimit) {
            outOfControlOneDay[nowDay()] = true;
            touchTimes = touchTimes.add(1);
            // modify difficutity
            if(touchTimes > touchLimits && touchLimits <= 8) {
                incomeLimit = incomeLimit.mul(120).div(100);
                touchTimes = 0;
                difficutityModiferTimes += 1;
                if(difficutityModiferTimes == 5) {
                    difficutityModiferTimes = 0;
                    touchLimits += 1;
                }
            }
        }
    }
}

contract DawnBreakContract is BasicContract {

    uint256 public maxLimit = pow6().mul(1000);
    uint256 public minLimit = pow6().mul(200);

    modifier invalidAmount(uint256 usdtAmount) {
        require(usdtAmount >= maxLimit && usdtAmount <= minLimit,"Invalid Amount!");
        _;
    }

    constructor(
        address _usdt_token_address,
    )
        public
    {
        startDay = nowDay();
        UsdtToken = UsdtInterface(_usdt_token_address);
        require(UsdtToken.totalSupply() > 0,"Invalid Token!");
    }

    function getRealData(
        uint256 day
    )
        public
        view
        returns(
            address[] memory _ivl,
            uint32[] memory _nl
        )
    {
        InvitePeople memory _iv = ivtb[day];
        return (_iv.ivl,_iv.nl);
    }

    function getPrizeRecord(
        uint256 day
    )
        public
        view
        returns(
            uint256[] memory _pal,
            address[] memory _al
        )
    {
        PrizeRecord memory _pr = prtb[day];
        return (_pr._pal,_pr._al);
    }

    function getSubInvestment(
        bytes32 _k,
        uint256 _i
    )
        public
        view
        returns(uint256,uint256,uint256,uint256,uint256,uint256)
    {
        Investment memory _inv = invtb[_k];
        SubInvestment memory si = _inv.siv[_i];
        return (si._cd,si._lrid,si._ct,si._c,si._ig,si._sg);
    }

    function getDayAmount(
        address _u,
        uint256 _day
    )
        public
        view
        returns(uint256)
    {
        Account storage _ac = actb[user];
        return _ac._ivood[_day];
    }
}
