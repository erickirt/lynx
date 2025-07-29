// Copyright 2025 The Lynx Authors. All rights reserved.
// Licensed under the Apache License Version 2.0 that can be found in the
// LICENSE file in the root directory of this source tree.

import { BusinessError } from '@kit.BasicServicesKit';
import { webSocket } from '@kit.NetworkKit';
import { buffer, util } from '@kit.ArkTS';
import { LLog, LynxContext, LynxModule } from '@lynx/lynx';

const TAG = 'LynxWebSocketModule';

export class LynxWebSocketModule extends LynxModule {
  private webSocketConnections: Map<number, webSocket.WebSocket>;

  constructor(context: LynxContext, param?: Object) {
    super(context, param);
    this.webSocketConnections = new Map<number, webSocket.WebSocket>();
  }

  public connect(url: string, protocols: Object[], options: Object[], id: number) {
    LLog.d(TAG, 'connect: ' + url);
    const ws = webSocket.createWebSocket();
    this.webSocketConnections.set(id, ws);
    ws.on('open', (err: BusinessError, value: Object) => {
      if (!err) {
        const arg: Record<string, Object> = {
          'id': id,
          'protocol': '',
        };
        this.sendEvent('websocketOpen', arg);
      }
    });
    ws.on('message', (err: BusinessError, value: string | ArrayBuffer) => {
      if (!err) {
        let type = 'text';
        if (buffer.isBuffer(value)) {
          const base64 = new util.Base64Helper();
          value = base64.encodeToStringSync(new Uint8Array((value as ArrayBuffer)));
          type = 'binary';
        }
        const arg: Record<string, Object> = {
          'id': id,
          'type': type,
          'data': value,
        };
        this.sendEvent('websocketMessage', arg);
      }
    });
    ws.on('close', (err: BusinessError, value: webSocket.CloseResult) => {
      if (!err) {
        const arg: Record<string, Object> = {
          'id': id,
          'code': value.code,
          'reason': value.reason,
        };
        this.sendEvent('websocketClosed', arg);
      }
    });
    ws.on('error', (err: BusinessError) => {
      this.notifyWebSocketFailed(id, err.message);
    });
    ws.connect(url, (err: BusinessError, value: boolean) => {
      if (err) {
        this.notifyWebSocketFailed(id, err.message, true);
      }
    });
  }

  public close(code: number, reason: string, id: number): void {
    const ws = this.webSocketConnections.get(id);
    if (ws) {
      ws.close((err: BusinessError, value: boolean) => {
        if (!err) {
          this.webSocketConnections.delete(id);
        } else {
          LLog.e(TAG, 'Could not close WebSocket connection for id ' + id + ', e:' + err.message);
        }
      });
    }
  }

  public send(message: string, id: number): void {
    const ws = this.webSocketConnections.get(id);
    if (ws) {
      ws.send(message, (err: BusinessError, value: boolean) => {
        if (err) {
          this.notifyWebSocketFailed(id, err.message);
        }
      });
    }
  }

  public ping(id: number) {
    const ws = this.webSocketConnections.get(id);
    if (ws) {
      ws.send('', (err: BusinessError, value: boolean) => {
        if (err) {
          this.notifyWebSocketFailed(id, err.message, true);
        }
      });
    } else {
      this.webSocketConnections.delete(id);
      this.notifyWebSocketFailed(id, 'client is null', true);
    }
  }

  public sendEvent(name: string, data: Object) {
    this.context.sendGlobalEvent(name, [data]);
  }

  private notifyWebSocketFailed(id: number, message: string, withClose = false) {
    const arg: Record<string, Object> = {
      'id': id,
      'message': message,
    };
    this.sendEvent('websocketFailed', arg);
    if (withClose) {
      const arg: Record<string, Object> = {
        'id': id,
        'code': 0,
        'reason': message,
      };
      this.sendEvent('websocketClosed', arg);
    }
  }
}
