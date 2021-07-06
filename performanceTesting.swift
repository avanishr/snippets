var totalTimeSpent: UInt64 = 0

func functionToTest() {
    //does something
}

func invokingFunction() {
    let startTime = DispatchTime.now()
    functionToTest()
    let endTime = DispatchTime.now()
    totalTimeSpent += endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
}
