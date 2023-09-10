// Shor's Factorization Algorithm
// Bryan Huang 9/4/23
// Based on Quantum Software Development Lab 9 by 2023 MITRE Corporation.

namespace ShorImplementation {

    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;

    

    operation FULL_SHOR (
        N: Int
    ) : (Int, Int) {

        mutable validPeriod = false;
        mutable p = 0;
        mutable g = 2;
        mutable gLimit = false;

        repeat{
            // 1a. Pick integer g such that 1 < g < N, N is the number to factor
            Message($"g candidate: {g}");

            // 1b. Compute GCD(g,N); if the result is > 1, GCD(g,N) is a factor of N.
            let gcd = GreatestCommonDivisorI(g,N);
            Message($"GCD check for g: {gcd}");
            if gcd > 1{
                Message($"Factor found (from g): {gcd}, {N/gcd}");
                return (gcd, N/gcd);
            }

            // 2. Find period of f(x) = g^x mod N, repeat until find p giving g^p mod N = 1
            //      - modular exponention is period if base and modulus are relatively prime
            //      - we ensure relatively prime in step 2
            //      - must repeat until success because qubit registers are uncertain

            set p = FindPeriod(N, g);

            // 3a. If p is odd or (g^(p/2) + 1) mod N = 0, period fails
            set validPeriod = TestPeriod(N,g,p);

            set g = g + 1;
            if g == N {
                set gLimit = true;
                Message("gLimit reached");
            }
        }
        until validPeriod or gLimit;
        Message($"p validated: {p}");

        // 3b-c. Compute GCD(g^(p/2) +- 1, N)
        //      - guaranteed to get at least one factor of N
        //      - calculate second factor
        mutable foundFactor = 0;
        mutable otherFactor = 0;

        let try1 = GreatestCommonDivisorI(g^(p/2)+1,N);
        if N % try1 == 0 and try1 != 1{
            set foundFactor = try1;
        }

        let try2 = GreatestCommonDivisorI(g^(p/2)-1,N);
        if N % try2 == 0 and try2 != 1{
            set foundFactor = try2;
        }

        set otherFactor = N/foundFactor;
        Message("--------------------------");
        Message($"foundFactor= {foundFactor}");
        Message($"otherFactor= {otherFactor}");
        return (foundFactor, otherFactor);
    }


    operation FindPeriod (
        N : Int,
        g : Int
    ) : Int {

        mutable found = false;
        mutable attempts = 0;
        mutable periodCandidate = 0;
        let n = Ceiling(Lg(IntAsDouble(N+1)));
        Message($"#qubits= {2*n}, ModExp qubit gates per attempt= {(2*n)^3}");

        repeat {
            set attempts = attempts +1;
            Message($"FindPeriod attempt #{attempts}:");
            // 2a, 2b. Allocate qubit registers of lengths:
            //      - n = Log(N+1,2)
            //      - input: 2*n
            //      - output (never greater than N): n 
            

            use (input, output) = (Qubit[2*n], Qubit[n]);

            // 2c. Apply Haddamard to put |I> into uniform superposition
            ApplyToEach(H,input);

            // 2d. Apply modular exponentiation function on |I,O>: |x,0> = {x,f(x)>
            ModExp(N, g, input, output);

            // 2e. Apply adjoint quantum fourier transform to |I>
            Adjoint QFT(BigEndian(input));

            // 2f. Measure |I> and obtain some value X
            let x = MeasureInteger(BigEndianAsLittleEndian(BigEndian(input)));
        
            ResetAll(input);
            ResetAll(output);

            // 2g. Use continued fraction expansion on X/(2^n)
            Message($"  > Fraction to expand: {x}/{2^(2*n)}");
            set periodCandidate = FractionExpansion(x, 2^(2*n), N);

            Message($"  > Period Candidate: {periodCandidate}");

            // 2h. Confirm validity of period, checking g^p mod N = 1
            if ExpModI(g, periodCandidate, N) == 1{
                set found = true;
            }
		}
        until found;

        return periodCandidate;
    }

    operation ModExp (
        N : Int,
        g : Int,
        input : Qubit[],
        output : Qubit[]
    ) : Unit {

        let l = Length(input);
        let l2 = Length(output);

        X(output[l2-1]);

        for i in 0..l-1{
            Controlled MultiplyByModularInteger(
                [input[l-i-1]], // control term, backwards to begin with least significant bit
                (ExpModI(g,2^i,N), N,LittleEndian(output)) //f(x) performed on output
            );
        }
        
    }

    // Quantum Fourier Transform
    operation QFT (register : BigEndian) : Unit is Adj + Ctl {
        let l = Length(register!);
       
        for i in 0..l-2{
            H(register![i]);
            for j in 2..l-i{
                Controlled R1Frac([register![j-1+i]],(2,j,register![i]));
            }
        }

        H(register![l-1]);

        SwapReverseRegister(register!);
    }

    function FractionExpansion (
        numerator : Int,
        denominator : Int,
        denominatorThreshold : Int
    ) : Int {

        mutable Pi = numerator;
        mutable Qi = denominator;

        mutable (mi2,mi1,mi) = (0,1,0);
        mutable (di2,di1,di) = (1,0,0);
        mutable ai = 0;
        mutable ri = 0;

        while(true){
            set ai = Pi/Qi;
            set ri = Pi%Qi;

            set mi = ai*mi1 + mi2;
            set di = ai*di1 + di2;

            if di >= denominatorThreshold{
                return di1;
            }
            if ri == 0{
                return di;
            }
            set Pi = Qi;
            set Qi = ri;

            set mi2 = mi1;
            set mi1 = mi;
            

            set di2 = di1;
            set di1 = di;
            

        }


        return -1;
        
    }

    function TestPeriod(
        N : Int,
        g : Int,
        p : Int
    ) : Bool{
        if p%2 == 1{ //p cannot be odd
            return false;
        }

        let num = ExpModI(g,p/2,N);

        if num == 1 or num == N-1{ //if true, then the factor we found is 1.
            return false;
        }
        return true;
    }

}

