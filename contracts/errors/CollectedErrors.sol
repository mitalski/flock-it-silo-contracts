// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Contract containing all collected custom errors
/* This file is generated automatically */

contract CollectedErrors {
    error AboveMaxLtv();
    error ActionsStopped();
    error AddressZero();
    error AlreadyConfigured();
    error AlreadyInitialized();
    error AmountExceedsAllowance();
    error BorrowNotPossible();
    error CantRemoveActiveGauge();
    error ClaimerUnauthorized();
    error CollateralSiloAlreadySet();
    error ConfigNotFound();
    error CrossReentrancyNotActive();
    error CrossReentrantCall();
    error CustomError1(uint256 a, uint256 b);
    error DaoFeeReceiverZeroAddress();
    error DaoMaxRangeExceeded();
    error DaoMinRangeExceeded();
    error DebtExistInOtherSilo();
    error DeployConfigFirst();
    error DeployedContractNotFound(string contractName);
    error DifferentRewardsTokens();
    error EarnedZero();
    error EmptyCoordinates();
    error EmptyGaugeAddress();
    error EmptyRecipient();
    error EmptyShareToken();
    error EmptySiloConfig();
    error EmptyToken0();
    error EmptyToken1();
    error FailedToCreateAnOracle(address _factory);
    error FailedToParseBoolean();
    error FeeOverflow();
    error FeeTooHigh();
    error FlashLoanNotPossible();
    error FlashloanAmountTooBig();
    error FlashloanFailed();
    error FullLiquidationRequired();
    error GaugeAlreadyConfigured();
    error GaugeIsNotConfigured();
    error HookIsZeroAddress();
    error HookReceiverMisconfigured();
    error IncentivesProgramAlreadyExists();
    error IncentivesProgramNotFound();
    error IncentivizedAssetMismatch();
    error IncentivizedAssetNotFound();
    error IndexOverflowAtEmissionsPerSecond();
    error InputCanBeAssetsOrShares();
    error InputZeroShares();
    error InvalidBeta();
    error InvalidCallBeforeQuote();
    error InvalidConfiguration();
    error InvalidDeployer();
    error InvalidDistributionEnd();
    error InvalidFeeRange();
    error InvalidIncentivesProgramName();
    error InvalidIrm();
    error InvalidKcrit();
    error InvalidKi();
    error InvalidKlin();
    error InvalidKlow();
    error InvalidLt();
    error InvalidMaxLtv();
    error InvalidQuoteToken();
    error InvalidRewardToken();
    error InvalidRi();
    error InvalidShareToken();
    error InvalidTcrit();
    error InvalidTimestamps();
    error InvalidToAddress();
    error InvalidUcrit();
    error InvalidUlow();
    error InvalidUopt();
    error InvalidUserAddress();
    error KeyIsTaken();
    error LiquidationTargetLtvTooHigh();
    error MaxDebtToCoverZero();
    error MaxDeployerFeeExceeded();
    error MaxFeeExceeded();
    error MaxFlashloanFeeExceeded();
    error MaxLiquidationFeeExceeded();
    error MissingHookReceiver();
    error NoDebtToCover();
    error NoLiquidity();
    error NoRepayAssets();
    error NotEnoughLiquidity();
    error NotHookReceiverOwner();
    error NotSolvent();
    error NothingToWithdraw();
    error OnlyDebtShareToken();
    error OnlyHookReceiver();
    error OnlyNotifier();
    error OnlyNotifierOrOwner();
    error OnlySilo();
    error OnlySiloConfig();
    error OnlySiloOrTokenOrHookReceiver();
    error OracleMisconfiguration();
    error OwnerIsZero();
    error OwnerIsZeroAddress();
    error OwnerNotFound();
    error RecipientIsZero();
    error RecipientNotSolventAfterTransfer();
    error RepayTooHigh();
    error RequestNotSupported();
    error ReturnZeroAssets();
    error ReturnZeroShares();
    error STokenNotSupported();
    error SameAsset();
    error SameRange();
    error SenderNotSolventAfterTransfer();
    error ShareTokenBeforeForbidden();
    error SiloFixtureHookReceiverImplNotFound(string hookReceiver);
    error SiloInitialized();
    error SiloNotFound();
    error SomeError();
    error TokenIsNotAContract();
    error TooLongProgramName();
    error UnableToRepayFlashloan();
    error UnexpectedCollateralToken();
    error UnexpectedDebtToken();
    error UnknownAction();
    error UnknownBorrowAction();
    error UnknownRatio();
    error UnknownShareTokenAction();
    error UnknownSwitchCollateralAction();
    error UnsupportedFlashloanToken();
    error UnsupportedNetworkForDeploy(string networkAlias);
    error UserIsSolvent();
    error UserSolvent();
    error WrongGaugeShareToken();
    error WrongSilo();
    error ZeroAddress();
    error ZeroAmount();
    error ZeroTransfer();
}
