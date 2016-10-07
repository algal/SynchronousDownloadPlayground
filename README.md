# Synchronous download in iOS

URLSession presents an API for asynchronous downloads.

But sometimes you want function that performs a *synchronous* download. This might be because you're calling that function within another mechanism (like GCD, or NSOperationQueues) that already handles performing the work in the background, and throttling the amount of work being performed in parallel, etc.. Or maybe you're working in a playground, and you are happy to wait for a synchronous network load just to keep things simple.

So in all those cases you want to _wrap your asynchronous function into a synchronous function_.

How should you do that?

This playground shows three ways to wrap an async download into a synchronous operation for use within a playground: using an asynchronous NSOperation, using GCD semaphores, and using polling. 

Implementations are in the sources folder.

Alexis
