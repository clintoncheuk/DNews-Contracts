// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 < 0.9.0;
import "./DNewsToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
}

contract DNews is Ownable {
    
    using SafeMath for uint256;

    event NewArticle(uint newsId, address author, string url);

    struct Article {
        address author;
        string url;
        uint id;
        uint upvote;
        uint downvote;
    }

    Article[] public articles;
    DNewsToken tokenContract;
    uint awardPerArticle = 10000000000000000000;

    constructor(DNewsToken _tokenContract) {
        tokenContract = _tokenContract;
    }

    function getAwardPerArticle() public view returns (uint) {
        return awardPerArticle;
    }

    function updateAwardPerArticle(uint _awardPerArticle) external onlyOwner {
        awardPerArticle = _awardPerArticle;
    }

    function createArticle(string memory _url) public {
        articles.push(Article(msg.sender, _url, articles.length.add(1), 0, 0));
        uint256 balance = tokenContract.balanceOf(address(this));
        require(awardPerArticle <= balance, "Not enough tokens in the reserve");
        tokenContract.transfer(msg.sender, awardPerArticle);
        emit NewArticle(articles.length.sub(1), msg.sender, _url);
    }

    function upvote(uint _id) public {
        articles[_id].upvote = articles[_id].upvote.add(1);
    }

    function downvote(uint _id) public {
        articles[_id].downvote = articles[_id].downvote.add(1);
    }

    function tokenBalance() public view returns(uint) {
        return tokenContract.balanceOf(address(this));
    }

    function getNewsArticlesCount() public view returns(uint) {
        return articles.length;
    }

    function getNewsArticles(uint fromIndex, uint toIndex) public view returns(Article[] memory) {
        require(fromIndex <= toIndex);
        uint length = toIndex - fromIndex;
        Article[] memory result = new Article[](length.add(1));
        for (uint i = fromIndex; i <= toIndex; i++) {
            result[i - fromIndex] = articles[i];
        }
        return result;
    }

}