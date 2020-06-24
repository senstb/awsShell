// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');

// Load credentials and set Region from JSON file
AWS.config.loadFromPath('./config.json');

//Load CloudFormation Constructor
const cf = new AWS.CloudFormation();

async function deployStack(stackname, params) {
	try {
		const stack = await cf.describeStacks().promise()
		if (JSON.stringify(stack).match(stackname) === null) {
			console.log("Creating " + stackname + " ...")
      await cf.createStack(params).promise()
      console.log("Running waitFor call...")
			const createComplete = await cf.waitFor("stackCreateComplete", { StackName: stackname }).promise()
			console.log("CREATE_COMPLETE - " + stackname)
			return createComplete
		} else {
			params.ChangeSetName = params.StackName + "-CS"
			await deployChangeSet(stackname, params)
		}
	} catch (e) {
		console.log(e, e.stack)
	}
}

async function deployChangeSet(stackname, params) {
	try {
		console.log("Computing changes for " + stackname)
		const stack = await cf.describeStacks().promise()
		if (JSON.stringify(stack).match(stackname) === null)
			params.ChangeSetType = "CREATE"
	
		await cf.createChangeSet(params).promise()
		const changeSetStatus = await cf.describeChangeSet({ ChangeSetName: params.ChangeSetName, StackName: params.StackName }).promise()
		if (changeSetStatus.Status === "FAILED") {
			await cf.deleteChangeSet({ChangeSetName: params.ChangeSetName, StackName: params.StackName }).promise()
			console.log("FAILED - " + stackname + "-CS")
			return changeSetStatus
		}
		await cf.waitFor("changeSetCreateComplete", { ChangeSetName: params.ChangeSetName, StackName: params.StackName }).promise()
		console.log("Executing " + stackname + "-CS")
		await cf.executeChangeSet({ ChangeSetName: params.ChangeSetName, StackName: params.StackName }).promise()

		if (JSON.stringify(stack).match(stackname) === null) {
			console.log("Creating " + stackname + " ...")
			const createComplete = await cf.waitFor("stackCreateComplete", { StackName: stackname }).promise()
			console.log("CREATE_COMPLETE - " + stackname)
			return createComplete
		} else {
			console.log("Updating " + stackname + " ...")
			const updateComplete = await cf.waitFor("stackUpdateComplete", { StackName: stackname }).promise()
			console.log("UPDATE_COMPLETE - " + stackname)
			return updateComplete
		}
	} catch (e) {
		console.log(e, e.stack)
	}
}

async function cfdeploy() {
	console.log("Starting CloudFormation deployment...")

	try {
		const macros = await deployStack("testStack", {
			StackName: "testStack",
			Parameters: [{ ParameterKey: "Param1", ParameterValue: "Value1" }],
			TemplateURL: "templateS3URL"
		})
		console.log(macros)
	} catch (e) {
		console.log(e, e.stack)
	}
}

cfdeploy()
