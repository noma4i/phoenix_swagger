defmodule PhoenixSwagger.JsonApiTest do
  use ExUnit.Case
  alias PhoenixSwagger.Schema
  import PhoenixSwagger

  doctest PhoenixSwagger.JsonApi

  swagger_definitions do
    JsonApi.resource(:User, :Users) do
      description "A user that may have one or more supporter pages."
      attributes do
        phone :string, "Users phone number"
        full_name :string, "Full name"
        user_updated_at :string, "Last update timestamp UTC", format: "ISO-8601"
        user_created_at :string, "First created timestamp UTC"
        email :string, "Email", required: true
        birthday :string, "Birthday in YYYY-MM-DD format"
        address Schema.ref(:Address)
      end
      link :self, "The link to this user resource"
      relationship :posts
    end

    {:Address, %Schema{
        type: "object",
        properties: %{
          street_address: %Schema{type: :string, description: "Street address"},
          region: %Schema{type: :string, description: "The users region"},
          postal_code: %Schema{type: :string, description: "The users postal / zip code"},
          locality: %Schema{type: :string, description: "???"},
          extended_address: %Schema{type: :string, description: "Extended address"},
          country: %Schema{type: :string, description: "Country"}
        }
      }
    }
  end

  test "produces expected paginated users schema" do
    users_schema = swagger_definitions["Users"]
    assert users_schema == %{
      "description" => "A page of [UserResource](#userresource) results",
      "properties" => %{
        "data" => %{
          "description" => "Content with [UserResource](#userresource) objects",
          "items" => %{"$ref" => "#/definitions/UserResource"},
          "type" => "array"
        },
        "links" => %{
          "properties" => %{
            "first" => %{"description" => "Link to the first page of results", "type" => "string"},
            "last" => %{"description" => "Link to the last page of results", "type" => "string"},
            "next" => %{"description" => "Link to the next page of results", "type" => "string"},
            "prev" => %{"description" => "Link to the previous page of results", "type" => "string"},
            "self" => %{"description" => "Link to this page of results", "type" => "string"}
          },
          "required" => ["self", "prev", "next", "last", "first"],
          "type" => "object"
        },
        "meta" => %{
          "properties" => %{
            "total-pages" => %{
              "description" => "The total number of pages available", "type" => "integer"
            }
          },
          "required" => ["total-pages"],
          "type" => "object"
        }
      },
      "required" => ["meta", "links", "data"],
      "type" => "object"
    }
  end

  test "produces expected user top level schema" do
    user_schema = swagger_definitions["User"]
    assert user_schema == %{
      "description" => "A JSON-API document with a single [UserResource](#userresource) resource",
      "properties" => %{
        "data" => %{
          "$ref" => "#/definitions/UserResource"
        },
        "links" => %{
          "properties" => %{
            "self" => %{
              "description" => "the link that generated the current response document.",
              "type" => "string"
            }
          },
          "required" => ["self"],
          "type" => "object"
        },
        "included" => %{
          "description" => "Included resources",
          "type" => "array"
        }
      },
      "required" => ["links", "data"],
      "type" => "object"
    }
  end

  test "produces expected address schema" do
    address_resource_schema = swagger_definitions["Address"]
    assert address_resource_schema == %{
      "properties" => %{
        "country" => %{"description" => "Country", "type" => "string"},
        "extended_address" => %{"description" => "Extended address", "type" => "string"},
        "locality" => %{"description" => "???", "type" => "string"},
        "postal_code" => %{"description" => "The users postal / zip code", "type" => "string"},
        "region" => %{"description" => "The users region", "type" => "string"},
        "street_address" => %{"description" => "Street address", "type" => "string"}
      },
      "type" => "object"
    }
  end

  test "produces expected user resource schema" do
    user_resource_schema = swagger_definitions["UserResource"]
    assert user_resource_schema == %{
      "description" => "A user that may have one or more supporter pages.",
      "type" => "object",
      "properties" => %{
        "id" => %{"description" => "The JSON-API resource ID", "type" => "string"},
        "type" => %{"description" => "The JSON-API resource type", "type" => "string"},
        "attributes" => %{
          "type" => "object",
          "properties" => %{
            "address" => %{"$ref" => "#/definitions/Address"},
            "birthday" => %{ "description" => "Birthday in YYYY-MM-DD format", "type" => "string"},
            "email" => %{"description" => "Email", "type" => "string"},
            "full_name" => %{"description" => "Full name", "type" => "string"},
            "phone" => %{"description" => "Users phone number", "type" => "string"},
            "user_created_at" => %{"description" => "First created timestamp UTC", "type" => "string"},
            "user_updated_at" => %{"description" => "Last update timestamp UTC", "type" => "string", "format" => "ISO-8601"}
          },
          "required" => ["email"]
        },
        "links" => %{
          "type" => "object",
          "properties" => %{
            "self" => %{"description" => "The link to this user resource", "type" => "string"}
          }
        },
        "relationships" => %{
          "type" => "object",
          "properties" => %{
            "posts" => %{
              "type" => "object",
              "properties" => %{
                "data" => %{
                  "type" => "object",
                  "properties" => %{
                    "id" => %{"description" => "Related posts resource id", "type" => "string"},
                    "type" => %{"description" => "Type of related posts resource", "type" => "string"}
                  }
                },
                "links" => %{
                  "type" => "object",
                  "properties" => %{
                    "related" => %{"description" => "Related posts link", "type" => "string"},
                    "self" => %{"description" => "Relationship link for posts", "type" => "string"}
                  }
                }
              }
            }
          }
        }
      }
    }
  end
end
