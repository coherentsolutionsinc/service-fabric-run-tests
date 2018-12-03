# What this image is about?

This image is designed to run Service Fabric oriented unit-tests (.NET Core) on Linux.

The latest version can be found on [DockerHub](https://hub.docker.com/r/coherentsolutions/service-fabric-run-tests/). 

Why is that needed?

Consider the following simple test:

``` csharp
public class MyStatefulService : Microsoft.ServiceFabric.Services.Runtime.StatefulService
{
    public MyStatefulService(
        StatefulServiceContext serviceContext)
        : base(serviceContext)
    {
    }

    protected override Task RunAsync(
        CancellationToken cancellationToken)
    {
        if (cancellationToken.IsCancellationRequested)
        {
            throw new InvalidOperationException();
        }
        return Task.CompletedTask;
    }
}

public class MyStatefulServiceTests
{
    [Fact]
    public async Task RunAsync_Should_raise_InvalidOperationException_When_CancellationToken_is_cancelled()
    {
        // Arrange
        var instance = new MyStatefulService(MockStatefulServiceContextFactory.Default);
        var cancellationTokenSource = new CancellationTokenSource();
        
        // Act, Assert
        cancellationTokenSource.Cancel();

        await Assert.ThrowsAsync<InvalidOperationException>(() => instance.InvokeRunAsync(cancellationTokenSource.Token));
    }
}
```

Despite it's simplicity this unit-test requires installed `servicefabric` runtime and `servicefabricsdkcommon` package installed to run. These packages cannot be installed as part of container build [see issue](https://github.com/Azure/service-fabric-issues/issues/1226).

The image solves the exactly this problem by performing manual copy of the required files from the packages.

# Versioning

The image use **runtime.ver-dotnetsdk.ver** version format i.e. image tag 6.3.129.1-2.1 indicates that current image has binaries from **servicefabric=6.3.129.1 runtime** and has **dotnet-2.1-sdk** installed.
