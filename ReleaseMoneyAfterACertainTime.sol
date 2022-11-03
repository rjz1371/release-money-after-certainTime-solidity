// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

// todo: add ability to cancel a payment under special conditions.

/// @author https://www.linkedin.com/in/reza-jabbari-47a10677
/// @notice Transfer money to a wallet address after a certain time.
contract ReleaseMoneyAfterACertainTime {

    // To hold payment information.
    struct PaymentInfo {
        uint amount;
        uint releaseTime;
        bool isSent;
    }

    // To hold the address that wants to transfer money and payment information.
    mapping(address => PaymentInfo[]) public paymentList;

    /**
    * @notice This function is used for creating payments to send after a certain time.
    * releaseAfter is in seconds. For example, if you want payment can be executed after 1 hour you should set it to 3600.
    *
    * @return bool.
    */
    function createPayment(address payToAddress, uint releaseAfter) public payable returns(bool) {
        require(msg.value > 0, "Please send a valid amount.");
        PaymentInfo memory pInfo = PaymentInfo({
            amount: msg.value,
            releaseTime: block.timestamp + releaseAfter,
            isSent: false
        });
        paymentList[payToAddress].push(pInfo);

        return true;
    }

    /**
    * @notice This function is used for seeing payment details.
    */
    function paymentDetails(address walletAddress, uint index) public view returns(uint _remainingSecondsToRelease, uint _amount, bool _isSent, bool _canMoneyBeTransferred) {
        PaymentInfo memory payment = paymentList[walletAddress][index];
        uint remainingSecondsToRelease = (payment.releaseTime >= block.timestamp) ? payment.releaseTime - block.timestamp : 0;
        bool canMoneyBeTransferred = canMoneyTransferred(payment.releaseTime);

        return (remainingSecondsToRelease, payment.amount, payment.isSent, canMoneyBeTransferred);
    }

    /**
    * @notice This function is used for executing the payment to transfer money.
    */
    function requestToExecutePayment(address walletAddress, uint index) public returns(bool) {
        PaymentInfo storage payment = paymentList[walletAddress][index];
        if (payment.amount > 0 && !payment.isSent && canMoneyTransferred(payment.releaseTime)) {
            payment.isSent = true;
            payable(walletAddress).transfer(payment.amount);
            return true;
        }

        return false;
    }

    /// internal function to check can money be transferred or not.
    function canMoneyTransferred(uint paymentReleaseTime) private view returns(bool) {
        return paymentReleaseTime <= block.timestamp;
    }
}
