// Shor's Factorization Algorithm Tests
// Bryan Huang 9/4/23
// Based on Quantum Software Development Lab 9 by 2023 MITRE Corporation.


namespace ShorTests {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;
    open ShorImplementation;

    @Test("QuantumSimulator")
    operation Factor4() : Unit {

        let N = 4;
        let a = 2;
        let b = 2;
        Message($"Factoring: {N}");
        let (x,y) = FULL_SHOR(N);
        if (not((x == a and y == b) or (x == b and y == a)))
        {
            fail $"Incorrect factors for {N}";
        }
	}
    @Test("QuantumSimulator")
    operation Factor6() : Unit {

        let N = 6;
        let a = 3;
        let b = 2;
        Message($"Factoring: {N}");
        let (x,y) = FULL_SHOR(N);
        if (not((x == a and y == b) or (x == b and y == a)))
        {
            fail $"Incorrect factors for {N}";
        }
	}

    @Test("QuantumSimulator")
    operation Factor9() : Unit {

        let N = 9;
        let a = 3;
        let b = 3;
        Message($"Factoring: {N}");
        let (x,y) = FULL_SHOR(N);
        if (not((x == a and y == b) or (x == b and y == a)))
        {
            fail $"Incorrect factors for {N}";
        }
	}

    @Test("QuantumSimulator")
    operation Factor10() : Unit {

        let N = 10;
        let a = 5;
        let b = 2;
        Message($"Factoring: {N}");
        let (x,y) = FULL_SHOR(N);
        if (not((x == a and y == b) or (x == b and y == a)))
        {
            fail $"Incorrect factors for {N}";
        }
	}

    @Test("QuantumSimulator")
    operation Factor25() : Unit {

        let N = 25;
        let a = 5;
        let b = 5;
        Message($"Factoring: {N}");
        let (x,y) = FULL_SHOR(N);
        if (not((x == a and y == b) or (x == b and y == a)))
        {
            fail $"Incorrect factors for {N}";
        }
	}

    @Test("QuantumSimulator")
    operation Factor14() : Unit {

        let N = 14;
        let a = 7;
        let b = 2;
        Message($"Factoring: {N}");
        let (x,y) = FULL_SHOR(N);
        if (not((x == a and y == b) or (x == b and y == a)))
        {
            fail $"Incorrect factors for {N}";
        }
	}

    @Test("QuantumSimulator")
    operation Factor15() : Unit {

        let N = 15;
        let a = 3;
        let b = 5;
        Message($"Factoring: {N}");
        let (x,y) = FULL_SHOR(N);
        if (not((x == a and y == b) or (x == b and y == a)))
        {
            fail $"Incorrect factors for {N}";
        }
	}

    @Test("QuantumSimulator")
    operation Factor21() : Unit {

        let N = 21;
        let a = 7;
        let b = 3;
        Message($"Factoring: {N}");
        let (x,y) = FULL_SHOR(N);
        if (not((x == a and y == b) or (x == b and y == a)))
        {
            fail $"Incorrect factors for {N}";
        }
	}

    @Test("QuantumSimulator")
    operation Factor15PeriodTest() : Unit {

        let N = 15;
        let g = 2;
        let x = FindPeriod(N, g);
        if (not(x==4))
        {
            fail $"Incorrect period for {N}, {g}";
        }
	}

    @Test("QuantumSimulator")
    operation Factor21PeriodTest() : Unit {

        let N = 21;
        let g = 2;
        let x = FindPeriod(N, g);
        if (not(x==6))
        {
            fail $"Incorrect period for {N}, {g}";
        }
	}
}
