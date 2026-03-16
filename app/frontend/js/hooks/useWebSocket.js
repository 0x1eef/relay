import {useEffect, useState} from "react"

const protocol = window.location.protocol === "https:" ? "wss:" : "ws:"

export default function useWebSocket(provider, model) {
  const [status, setStatus] = useState("connecting")
  const [entries, setEntries] = useState([])
  const [streaming, setStreaming] = useState("")
  const [socket, setSocket] = useState(null)

  const say = (text) => {
    setEntries((prev) => [...prev, {kind: "system", text}])
  }

  const tell = (text) => {
    setEntries((prev) => [...prev, {kind: "user", text}])
  }

  useEffect(() => {
    if (!model) return
    const socket = new WebSocket(
      `${protocol}//${window.location.host}/ws?provider=${encodeURIComponent(provider)}&model=${encodeURIComponent(model)}`
    )
    setSocket(socket)
    setStatus("connecting")
    const stream = (chunk) => {
      setStreaming((prev) => prev + chunk)
    }
    const finish = () => {
      setStreaming((current) => {
        if (current) setEntries((prev) => [...prev, {kind: "assistant", markdown: current}])
        return ""
      })
    }
    socket.addEventListener("open", () => {
      setStatus("ready")
    })
    socket.addEventListener("close", () => {
      setStatus("closed")
    })
    socket.addEventListener("error", () => {
      setStatus("error")
      say("client: socket error")
    })
    socket.addEventListener("message", (event) => {
      try {
        const payload = JSON.parse(event.data)
        switch (payload.event) {
          case "welcome":
            say(`server: connected (${payload.provider || provider}${payload.model ? ` / ${payload.model}` : ""})`)
            break
          case "status":
            setStatus(payload.message)
            break
          case "delta":
            stream(payload.message)
            break
          case "done":
            finish()
            setStatus("ready")
            break
          case "error":
            setStreaming("")
            setStatus("error")
            say("server: server error")
            break
          default:
            break
        }
      } catch {
        say("client: recv failed")
      }
    })

    return () => socket.close()
  }, [provider, model])

  const send = (message) => {
    if (!socket || socket.readyState !== WebSocket.OPEN) {
      say("client: socket is not open")
      return false
    }
    setStatus("waiting")
    tell(message)
    socket.send(message)
    return true
  }

  return {
    entries,
    send,
    status,
    streaming
  }
}
