Imports System
Imports System.Threading.Tasks
Imports System.Collections.Generic
Imports System.Numerics
Imports Nethereum.Hex.HexTypes
Imports Nethereum.ABI.FunctionEncoding.Attributes
Imports Nethereum.Web3
Imports Nethereum.RPC.Eth.DTOs
Imports Nethereum.Contracts.CQS
Imports Nethereum.Contracts.ContractHandlers
Imports Nethereum.Contracts
Imports System.Threading
Imports Individual lending.Contracts.time.ContractDefinition
Namespace Individual lending.Contracts.time


    Public Partial Class TimeService
    
    
        Public Shared Function DeployContractAndWaitForReceiptAsync(ByVal web3 As Nethereum.Web3.Web3, ByVal timeDeployment As TimeDeployment, ByVal Optional cancellationTokenSource As CancellationTokenSource = Nothing) As Task(Of TransactionReceipt)
        
            Return web3.Eth.GetContractDeploymentHandler(Of TimeDeployment)().SendRequestAndWaitForReceiptAsync(timeDeployment, cancellationTokenSource)
        
        End Function
         Public Shared Function DeployContractAsync(ByVal web3 As Nethereum.Web3.Web3, ByVal timeDeployment As TimeDeployment) As Task(Of String)
        
            Return web3.Eth.GetContractDeploymentHandler(Of TimeDeployment)().SendRequestAsync(timeDeployment)
        
        End Function
        Public Shared Async Function DeployContractAndGetServiceAsync(ByVal web3 As Nethereum.Web3.Web3, ByVal timeDeployment As TimeDeployment, ByVal Optional cancellationTokenSource As CancellationTokenSource = Nothing) As Task(Of TimeService)
        
            Dim receipt = Await DeployContractAndWaitForReceiptAsync(web3, timeDeployment, cancellationTokenSource)
            Return New TimeService(web3, receipt.ContractAddress)
        
        End Function
    
        Protected Property Web3 As Nethereum.Web3.Web3
        
        Public Property ContractHandler As ContractHandler
        
        Public Sub New(ByVal web3 As Nethereum.Web3.Web3, ByVal contractAddress As String)
            Web3 = web3
            ContractHandler = web3.Eth.GetContractHandler(contractAddress)
        End Sub
    
        Public Function AmmountBorrowQueryAsync(ByVal ammountBorrowFunction As AmmountBorrowFunction, ByVal Optional blockParameter As BlockParameter = Nothing) As Task(Of BigInteger)
        
            Return ContractHandler.QueryAsync(Of AmmountBorrowFunction, BigInteger)(ammountBorrowFunction, blockParameter)
        
        End Function

        
        Public Function AmmountBorrowQueryAsync(ByVal Optional blockParameter As BlockParameter = Nothing) As Task(Of BigInteger)
        
            return ContractHandler.QueryAsync(Of AmmountBorrowFunction, BigInteger)(Nothing, blockParameter)
        
        End Function



        Public Function CoinXsecontRequestAsync(ByVal coinXsecontFunction As CoinXsecontFunction) As Task(Of String)
                    
            Return ContractHandler.SendRequestAsync(Of CoinXsecontFunction)(coinXsecontFunction)
        
        End Function

        Public Function CoinXsecontRequestAsync() As Task(Of String)
                    
            Return ContractHandler.SendRequestAsync(Of CoinXsecontFunction)
        
        End Function

        Public Function CoinXsecontRequestAndWaitForReceiptAsync(ByVal coinXsecontFunction As CoinXsecontFunction, ByVal Optional cancellationToken As CancellationTokenSource = Nothing) As Task(Of TransactionReceipt)
        
            Return ContractHandler.SendRequestAndWaitForReceiptAsync(Of CoinXsecontFunction)(coinXsecontFunction, cancellationToken)
        
        End Function

        Public Function CoinXsecontRequestAndWaitForReceiptAsync(ByVal Optional cancellationToken As CancellationTokenSource = Nothing) As Task(Of TransactionReceipt)
        
            Return ContractHandler.SendRequestAndWaitForReceiptAsync(Of CoinXsecontFunction)(Nothing, cancellationToken)
        
        End Function
        Public Function DifferentTImeQueryAsync(ByVal differentTImeFunction As DifferentTImeFunction, ByVal Optional blockParameter As BlockParameter = Nothing) As Task(Of BigInteger)
        
            Return ContractHandler.QueryAsync(Of DifferentTImeFunction, BigInteger)(differentTImeFunction, blockParameter)
        
        End Function

        
        Public Function DifferentTImeQueryAsync(ByVal Optional blockParameter As BlockParameter = Nothing) As Task(Of BigInteger)
        
            return ContractHandler.QueryAsync(Of DifferentTImeFunction, BigInteger)(Nothing, blockParameter)
        
        End Function



        Public Function InterestXamounSecontQueryAsync(ByVal interestXamounSecontFunction As InterestXamounSecontFunction, ByVal Optional blockParameter As BlockParameter = Nothing) As Task(Of InterestXamounSecontOutputDTO)
        
            Return ContractHandler.QueryDeserializingToObjectAsync(Of InterestXamounSecontFunction, InterestXamounSecontOutputDTO)(interestXamounSecontFunction, blockParameter)
        
        End Function

        
        Public Function InterestXamounSecontQueryAsync(ByVal Optional blockParameter As BlockParameter = Nothing) As Task(Of InterestXamounSecontOutputDTO)
        
            return ContractHandler.QueryDeserializingToObjectAsync(Of InterestXamounSecontFunction, InterestXamounSecontOutputDTO)(Nothing, blockParameter)
        
        End Function



        Public Function ReturnTimestampQueryAsync(ByVal returnTimestampFunction As ReturnTimestampFunction, ByVal Optional blockParameter As BlockParameter = Nothing) As Task(Of BigInteger)
        
            Return ContractHandler.QueryAsync(Of ReturnTimestampFunction, BigInteger)(returnTimestampFunction, blockParameter)
        
        End Function

        
        Public Function ReturnTimestampQueryAsync(ByVal Optional blockParameter As BlockParameter = Nothing) As Task(Of BigInteger)
        
            return ContractHandler.QueryAsync(Of ReturnTimestampFunction, BigInteger)(Nothing, blockParameter)
        
        End Function



    
    End Class

End Namespace
