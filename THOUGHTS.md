Started by forking the project to my own Github so I could freely work on a copy.

Since I've never worked with next.js nor pnpm I had to go read a bit about it and found that by exeucting corepack use pnpm@latest I would be able to install dependencies. 

I ran docker-compose up --build but then I saw only postgres was uncommented so I uncomment the application too.

I realized that I needed to build a dockerfile to build and run a nextjs application using pnpm, so after some google searches I found this: https://github.com/mpash/pnpm-next-docker.

Since I don't know a lot of pnpm I decided to implement a logical version of what I usually do with npm when building a nestjs app.
Sadly, since I also don't know a lot about nextjs, I copied the entire .next directory into the container, but I'm sure this could be improved.

Now it is time to do the CI/CD Part, since I'm much more fluent on AWS I'll use Codepipeline for this, I'll set this up through Terraform so I can also show my knowledge with it.