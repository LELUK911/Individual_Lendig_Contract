Imports System
Imports System.Threading.Tasks
Imports System.Collections.Generic
Imports System.Numerics
Imports Nethereum.Hex.HexTypes
Imports Nethereum.ABI.FunctionEncoding.Attributes
Imports Nethereum.Web3
Imports Nethereum.RPC.Eth.DTOs
Imports Nethereum.Contracts.CQS
Imports Nethereum.Contracts
Imports System.Threading
Namespace Individual lending.Contracts.time.ContractDefinition

    
    
    Public Partial Class TimeDeployment
     Inherits TimeDeploymentBase
    
        Public Sub New()
            MyBase.New(DEFAULT_BYTECODE)
        End Sub
        
        Public Sub New(ByVal byteCode As String)
            MyBase.New(byteCode)
        End Sub
    
    End Class

    Public Class TimeDeploymentBase 
            Inherits ContractDeploymentMessage
        
        Public Shared DEFAULT_BYTECODE As String = "6080604052683635c9adc5dea00000600055611b586001556276a70060025534801561002a57600080fd5b50426003556101dd8061003e6000396000f3fe608060405234801561001057600080fd5b50600436106100575760003560e01c8063143914241461005c5780631e633a7314610078578063443dedf31461007e57806346a793f114610086578063b42663c11461008e575b600080fd5b61006560045481565b6040519081526020015b60405180910390f35b42610065565b6100656100ab565b6100656100c0565b610096610114565b6040805192835260208301919091520161006f565b6000600354426100bb919061017a565b905090565b60035460009042906301da9c00906100d8908361017a565b6103e86001546100e89190610139565b6000546100f5919061015b565b6100ff919061015b565b6101099190610139565b600481905592915050565b60008060006101216100ab565b905080600454610131919061015b565b939092509050565b60008261015657634e487b7160e01b600052601260045260246000fd5b500490565b600081600019048311821515161561017557610175610191565b500290565b60008282101561018c5761018c610191565b500390565b634e487b7160e01b600052601160045260246000fdfea264697066735822122033b195070b3dc88cd585e9e6e35b73ae4254308f490c1492ea43091ed0f4681064736f6c63430008070033"
        
        Public Sub New()
            MyBase.New(DEFAULT_BYTECODE)
        End Sub
        
        Public Sub New(ByVal byteCode As String)
            MyBase.New(byteCode)
        End Sub
        

    
    End Class    
    
    Public Partial Class AmmountBorrowFunction
        Inherits AmmountBorrowFunctionBase
    End Class

        <[Function]("ammountBorrow", "uint256")>
    Public Class AmmountBorrowFunctionBase
        Inherits FunctionMessage
    

    
    End Class
    
    
    Public Partial Class CoinXsecontFunction
        Inherits CoinXsecontFunctionBase
    End Class

        <[Function]("coinXsecont", "uint256")>
    Public Class CoinXsecontFunctionBase
        Inherits FunctionMessage
    

    
    End Class
    
    
    Public Partial Class DifferentTImeFunction
        Inherits DifferentTImeFunctionBase
    End Class

        <[Function]("differentTIme", "uint256")>
    Public Class DifferentTImeFunctionBase
        Inherits FunctionMessage
    

    
    End Class
    
    
    Public Partial Class InterestXamounSecontFunction
        Inherits InterestXamounSecontFunctionBase
    End Class

        <[Function]("interestXamounSecont", GetType(InterestXamounSecontOutputDTO))>
    Public Class InterestXamounSecontFunctionBase
        Inherits FunctionMessage
    

    
    End Class
    
    
    Public Partial Class ReturnTimestampFunction
        Inherits ReturnTimestampFunctionBase
    End Class

        <[Function]("returnTimestamp", "uint256")>
    Public Class ReturnTimestampFunctionBase
        Inherits FunctionMessage
    

    
    End Class
    
    
    Public Partial Class AmmountBorrowOutputDTO
        Inherits AmmountBorrowOutputDTOBase
    End Class

    <[FunctionOutput]>
    Public Class AmmountBorrowOutputDTOBase
        Implements IFunctionOutputDTO
        
        <[Parameter]("uint256", "", 1)>
        Public Overridable Property [ReturnValue1] As BigInteger
    
    End Class    
    
    
    
    Public Partial Class DifferentTImeOutputDTO
        Inherits DifferentTImeOutputDTOBase
    End Class

    <[FunctionOutput]>
    Public Class DifferentTImeOutputDTOBase
        Implements IFunctionOutputDTO
        
        <[Parameter]("uint256", "", 1)>
        Public Overridable Property [ReturnValue1] As BigInteger
    
    End Class    
    
    Public Partial Class InterestXamounSecontOutputDTO
        Inherits InterestXamounSecontOutputDTOBase
    End Class

    <[FunctionOutput]>
    Public Class InterestXamounSecontOutputDTOBase
        Implements IFunctionOutputDTO
        
        <[Parameter]("uint256", "", 1)>
        Public Overridable Property [ReturnValue1] As BigInteger
        <[Parameter]("uint256", "", 2)>
        Public Overridable Property [ReturnValue2] As BigInteger
    
    End Class    
    
    Public Partial Class ReturnTimestampOutputDTO
        Inherits ReturnTimestampOutputDTOBase
    End Class

    <[FunctionOutput]>
    Public Class ReturnTimestampOutputDTOBase
        Implements IFunctionOutputDTO
        
        <[Parameter]("uint256", "", 1)>
        Public Overridable Property [ReturnValue1] As BigInteger
    
    End Class
End Namespace
