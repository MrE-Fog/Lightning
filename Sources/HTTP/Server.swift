//
//  HTTP.swift
//  Edge
//
//  Created by Tyler Fleming Cloutier on 6/22/16.
//
//

import Dispatch
import Reflex
import POSIX
import TCP

public final class Server {

    public init() {}

    public func listen(host: String, port: POSIX.Port) -> Source<ClientConnection, SystemError> {
        return Source { observer in

            let tcpServer = try! TCP.Server()
            try! tcpServer.bind(host: host, port: port)

            let listen = tcpServer.listen()
            listen.onNext { socket in
                observer.sendNext(ClientConnection(socket: socket))
            }

            listen.onFailed { error in
                observer.sendFailed(error)
            }

            listen.start()

            return ActionDisposable {
                listen.stop()
            }
        }
    }
}
