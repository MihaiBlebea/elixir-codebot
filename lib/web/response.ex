defmodule Codebot.Web.Response do

    defstruct message: nil,
        type: nil,
        image: nil,
        title: nil,
        description: nil,
        link: nil,
        list: nil

    @spec newMessage(binary, :message) :: %Codebot.Web.Response{}
    def newMessage(message, :message) do
        %Codebot.Web.Response{
            message: message,
            type: :message
        }
    end

    @spec newMessage(binary, :card, binary, binary, binary, binary) :: %Codebot.Web.Response{}
    def newMessage(message, :card, image, title, description, link) do
        %Codebot.Web.Response{
            message: message,
            type: :card,
            image: image,
            title: title,
            description: description,
            link: link
        }
    end

    @spec newMessage(binary, :list, binary, list) :: %Codebot.Web.Response{}
    def newMessage(message, :list, link, list) do
        %Codebot.Web.Response{
            message: message,
            type: :list,
            list: list,
            link: link
        }
    end
end
