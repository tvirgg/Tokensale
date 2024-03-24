import { time } from '@nomicfoundation/hardhat-toolbox/network-helpers'
import { ethers } from 'hardhat'

async function main() {
	const currentTimestampInSeconds = Math.round(Date.now() / 1000)
	const unlockTime = currentTimestampInSeconds + 60

	const lockedAmount = ethers.parseEther('0.001')

	const lock = await ethers.deployContract('Lock', [unlockTime], {
		value: lockedAmount,
	})

	await lock.waitForDeployment()

	console.log(
		`Lock with ${ethers.formatEther(
			lockedAmount,
		)}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`,
	)

	await time.increase(unlockTime)

	await lock.withdraw()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exitCode = 1
	})