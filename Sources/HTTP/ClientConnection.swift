//
//  ClientConnection.swift
//  Edge
//
//  Created by Tyler Fleming Cloutier on 7/9/16.
//
//

import Foundation
import TCP
import StreamKit
import POSIX

public final class ClientConnection {

    let socket: TCP.Socket
    var parser = RequestParser()

    init(socket: TCP.Socket) {
        self.socket = socket
    }

    public func read() -> Source<Request, ClientError> {
        return Source { observer in
            let read = self.socket.read()
            self.parser.onRequest = { request in
                observer.sendNext(request)
            }

            read.onNext { data in
                do {
                    try self.parser.parse(data)
                } catch {
                    // Respond with 400 error
                    observer.sendFailed(.badRequest)
                }
            }
            read.start()

            return ActionDisposable {
                read.stop()
            }
        }
    }

    public func write(_ response: Response) -> Source<[UInt8], SystemError> {
        return socket.write(buffer: response.serialized)
    }

}
