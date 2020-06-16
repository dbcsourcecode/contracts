##### **About DAWNBREAK**
---
Dawnbreak is a decentralized smart contract investment and wealth management platform, see [https://dbcen.github.io/dawnbreak](https://dbcen.github.io/dawnbreak)

##### **Introduction**
---

- **Spirit of Contract**

The spirit of contract and humanism are the cornerstones of modern social civilization.

From the beginning of the Aristotle era, let the human civilization be guided by the basis of justice exchange, Aquinas said, "So far, the progressive movement of all societies has been a'from identity to contract' movement." "Talented human rights" is the foundation and the premise of the "state of nature" is that the contract has changed the way of human communication. It has transformed humanity from ignorance to modernity, and transformed the earth from countless divided regions into today's global village.

The spirit of contract laid the foundation for the commercial society and the spirit of the rule of law, and provided guarantees for the protection of social order and human rights.

- **The weight of the balance of justice**

This is interesting. Although the spirit of the contract has been guiding mankind forward, I have to admit that the limitations of human beings allow the contract to restrict human beings while guiding them.
For example, the duration of the contract cannot be determined, the design of the contract is not widely applicable, there are always various problems in the execution of the contract, and the measure of the penalty for breach of contract.

The establishment of the economic contract is to satisfy humanity's measurement of transaction value, and the establishment of the social contract is to satisfy humanity's pursuit of social fairness. It should be known that this is the foundation of the establishment of the social contract and the satisfaction of the people's pursuit of basic rights in life. A perfect and properly executed contract is the ultimate weight of the social justice balance.

- **It's time to do something**

Survival is the root of human suffering. Unbearable life is the extreme point of human anger. Unfair distribution is a prerequisite for human resistance. Perhaps, it is time to solve the problem from a new perspective and design a contract that meets human needs. The model, which has a built-in perfect incentive mechanism, builds a benign input-output plan, and avoids the past irresistible moral hazard.

Mankind needs such a brand-new contract execution model to satisfy mankind's eternal pursuit of fairness, justice and openness.
From the perspective of the reconstruction of the organizational model and the behavior process, to curb the evil of human nature and build a new social model of human beings.

The contract is never a shackle to our outside, but a construction of our inner yearning order!

Contract
 
Good luck
3301

##### **Source Code**
---
```solidity

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

    /**
     * @dev Check the contract address
     */
    function is_contract(address contract_address)
        public
        view
        returns(uint256 size)
    {
        assembly {
            size := extcodesize(contract_address)
        }
    }

    function generate_id(
		address user
	)
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
        require(is_contract(user) == 0,"no cantract user!");
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

    function limitControl(uint256 amount)
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
    mapping(uint256 => uint256) public jackpot;
    mapping(bytes32 => bool) public keyExsiten;

    modifier invalidAmount(uint256 usdtAmount) {
        require(usdtAmount >= maxLimit && usdtAmount <= minLimit,"Invalid Amount!");
        _;
    }

    constructor(
        address _usdt_token_address,
    )
        public
    {
        _sd = nowDay();
        UsdtToken = UsdtInterface(_usdt_token_address);
        require(UsdtToken.totalSupply() > 0,"Invalid Token!");
    }

    function getRealInviteData(
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

    function getOnePrizeRecord(
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

    function getOneSubInvestment(
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

    function getOneDayAmount(
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
```
